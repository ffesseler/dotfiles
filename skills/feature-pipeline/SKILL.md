---
name: feature-pipeline
description: "Orchestrate a full feature delivery pipeline from an approved high-level plan: fresh-context plan critique by an external LLM CLI, then step-by-step implementation in fresh-context agents with per-substep commits, cross-model step reviews, and progress logging in the plan file. Use when the user wants to run, resume, or continue a plan through the pipeline (e.g. '/feature-pipeline plans/x.md', 'lance le pipeline', 'continue the pipeline'). Not for writing the plan itself (use high-level-planner) or for ad-hoc edits."
---

# Feature Pipeline

Automate the delivery workflow: **plan critique → step execution loop → done**. State
lives in the plan file (frontmatter + execution log), so the pipeline is resumable from
any new session.

```
high-level plan (already written, user-reviewed)
  │
  ├─ PHASE critique : fresh-context external review of the plan → triage → integrate
  │
  ├─ PHASE execute  : for each step
  │     1. spawn fresh-context step agent → detailed plan → (validation) → implement
  │     2. one commit per substep (commit-message conventions, targeted staging)
  │     3. cross-model review of the step's commits vs the plan → triage → fixes
  │     4. mark step done + append execution log entry
  │
  └─ PHASE done     : final summary
```

## Invocation & Resume

Preferred invocations:

- Claude Code skill command: `/feature-pipeline <plan-file> [key=value overrides]`
- Pi prompt template: `/feature-pipeline <plan-file> [key=value overrides]`
- Pi skill command fallback: `/skill:feature-pipeline <plan-file> [key=value overrides]`

1. Read the plan file. If missing/unreadable, ask for the path and stop.
2. If it has a `pipeline:` frontmatter block → resume from `phase` (and from the first
   step not marked done, using the execution log).
3. If not → run **Init** below.

`key=value` overrides apply in both cases (e.g. `phase=execute` to adopt an
in-progress plan without re-running the critique, `engine=codex` for one plan,
`max_steps=3` to stop after three completed steps in this invocation).

Re-invoking on a finished plan (`phase: done`) just reports the final state.

## Config (plan frontmatter)

The pipeline owns a YAML frontmatter block at the top of the plan file:

```yaml
---
pipeline:
  autonomy: step        # substep | step | full
  triage: interactive   # interactive | auto | raw
  engine: claude        # claude | gemini | codex | pi | opencode, with optional model
  phase: critique       # critique | execute | done
  max_steps: null       # optional positive integer limit for this run
---
```

- `autonomy`
  - `substep`: user validates the detailed plan, then each substep after its commit.
  - `step`: user validates the detailed plan, then the whole step after its cross-review.
  - `full`: no user checkpoints; reviews are auto-triaged; report at the end.
- `triage` (applies to both review phases)
  - `interactive`: classify findings and let the user pick what to integrate.
  - `auto`: integrate `blocking` + `major` findings, log discarded ones with reasons.
  - `raw`: show the full review output and wait for instructions.
- `engine`: which CLI runs the fresh-context reviews (via `scripts/fresh-review`).
  Accepts an optional model suffix `engine:model` passed to the CLI's `--model` flag,
  e.g. `claude:opus`, `gemini:gemini-2.5-pro`, `codex:o3`. Without a suffix the CLI's
  own configured default applies — note that `claude` then uses the user's default
  model, which may be the same model running the pipeline (less review diversity).
- `max_steps`: optional positive integer limiting how many plan steps are executed in
  the current invocation. It counts only successfully closed implementation steps, not
  the critique phase, review-fix commits, or already-completed steps. When the limit is
  reached and unfinished steps remain, keep `phase: execute`, report the next step, and
  stop cleanly so the next invocation resumes normally. If a command-line override sets
  `max_steps`, treat it as a per-run limit; do not persist or preserve it unless the
  user explicitly asks for a sticky limit in the plan frontmatter.

## Runtime resources

Resolve all bundled resources relative to this skill directory (the directory containing
this `SKILL.md`), not relative to the current repository and not via a hard-coded
Claude-only path:

- `FEATURE_PIPELINE_SKILL_DIR`: this skill directory.
- `FRESH_REVIEW`: `$FEATURE_PIPELINE_SKILL_DIR/scripts/fresh-review`.
- Prompt templates: `$FEATURE_PIPELINE_SKILL_DIR/references/*.md`.

When filling `references/step-agent-prompt.md`, also resolve optional cross-skill
references before spawning the step agent:

- `DETAILED_PLANNING_PATH`: first existing detailed-planning reference from the
  installed `plan-executor` skill. Check sibling skills first
  (`$FEATURE_PIPELINE_SKILL_DIR/../plan-executor/...`), then common Claude/Pi global
  and project locations (`~/.claude/skills`, `~/.pi/agent/skills`, `.pi/skills`,
  `.pi/agent/skills`, `.agents/skills`). If none exists, pass `unavailable` and let the
  step prompt's fallback rules apply.
- `COMMIT_MESSAGE_SKILL_PATH`: first existing `commit-message/SKILL.md` from installed
  skills, using the same sibling/global/project search order. If none exists, pass
  `unavailable` and use the repository's commit style from recent `git log` subjects.

### Init (no frontmatter yet)

1. Detect whether the plan is already in progress: steps marked completed, or an
   existing progress/log section. If so, this is an **adoption**: default `phase` to
   `execute` (skip the critique — the plan was already frozen and partially executed),
   summarize the detected state (done steps, next step) and confirm it with the user.
   A fresh plan defaults to `phase: critique`.
2. Ask the user for `autonomy`, `triage`, `engine`, and optionally `max_steps` in one
   question round (AskUserQuestion when available, otherwise plain questions). Defaults
   to offer: `step` / `interactive` / `claude` / no step limit. Validate `max_steps` as
   either omitted/null or a positive integer.
3. Write the frontmatter block at the top of the plan file.
4. Ensure the plan has an execution log section: reuse an existing one whatever its
   name (`## Execution Log`, `## Progress Log`, ...) and keep appending in its format;
   create `## Execution Log` only if none exists.
4. Verify preconditions: clean-enough worktree (warn on unstaged changes that could get
   mixed into step commits — ask the user to stash/commit them first), and `engine` CLI
   present on PATH.

## Phase: critique

1. Read `references/plan-critique-prompt.md`, fill the template (plan path, repo root,
   skill directory), write it to a temp file.
2. Run: `"$FRESH_REVIEW" <engine> <prompt-file>
   plans/reviews/<plan-slug>-critique-<yyyyMMdd-HHmmss>.md`
   (review outputs are kept in `plans/reviews/` for traceability).
3. Parse the findings and run **Triage** (below).
4. Apply the accepted findings as edits to the plan body. Record a one-line entry in the
   execution log: review file path, counts of accepted/discarded findings.
5. Set `phase: execute`. If `triage: interactive`, confirm with the user before moving
   on ("plan figé, on lance l'exécution ?").

## Phase: execute

Initialize `steps_completed_this_run = 0`. Loop until no steps remain, or until
`max_steps` successfully closed steps have been completed in this invocation. For each
step:

### 1. Select & snapshot

- Pick the first step not marked done (per plan checkboxes/log). Announce it.
- Record `START_SHA=$(git rev-parse HEAD)`.

### 2. Spawn the step agent (fresh context)

- Read `references/step-agent-prompt.md`, fill the template (step number/title,
  autonomy, paths, `FEATURE_PIPELINE_SKILL_DIR`, `DETAILED_PLANNING_PATH`, and
  `COMMIT_MESSAGE_SKILL_PATH`). One agent per step; a new step always gets a new
  fresh-context agent.
- Runtime adapter:
  - **Claude Code**: spawn `general-purpose` with the Agent tool. Continue the same
    child with SendMessage for approvals, adjustments, substep continuation, and review
    fixes.
  - **Pi with subagent tool**: before the first delegation, inspect available agents
    with `subagent({ action: "list" })` if not already known. Spawn a fresh worker with
    `subagent({ agent: "worker", context: "fresh", task: <filled prompt>, ... })`.
    Prefer async when the parent can keep working; otherwise foreground is acceptable
    for checkpoint-heavy runs. Record the returned run id. Continue the same child with
    `subagent({ action: "resume", id: <run id>, message: "approved, implement" })`,
    `message: "continue"`, adjustment requests, or accepted review findings.
  - **No agent/subagent primitive**: execute the step inline in the current session,
    following the filled step prompt yourself. State stays in the plan file; recommend
    the user restart a fresh session between steps and re-invoke the pipeline (resume
    handles the rest).
- The agent first produces `plans/step-NN-detailed-plan.md` and, unless `autonomy:
  full`, returns for validation. Relay the detailed plan summary to the user. Before
  approval, explicitly verify that any numbered substeps are understood as commit
  boundaries: **one detailed-plan substep = one focused commit**.
- On approval, continue the SAME child using the runtime's continuation primitive with
  an explicit instruction such as: "approved, implement exactly substep-by-substep; make
  one focused commit per numbered substep before starting the next; do not batch
  substeps into one commit". On adjustments, relay them and re-validate.
- In `substep` autonomy: each time the child returns a substep report, verify that the
  reported commit corresponds to that substep, relay it (commits, changes, validation)
  and ask the user to validate; then continue the same child with "continue" (or the
  adjustment requests). Repeat until step-done.
- In `step`/`full`: the child runs all substeps and returns once, but must still create
  one commit per detailed-plan substep.
- If the child returns `STATUS: blocked`, surface it to the user and stop the loop
  (in `full` mode too — blocked means a human decision is needed).

### 3. Cross-model step review

- `END_SHA=$(git rev-parse HEAD)`. If no commits were made, skip the review and flag it.
- Before launching the review, compare the detailed plan's numbered substeps with
  `git log --oneline START_SHA..END_SHA` and the child report. If the step had multiple
  planned substeps but the commit range does not map to one focused commit per substep,
  treat it as a pipeline violation: do not mark the step done. Surface it to the user.
  Without explicit user approval, do not amend/rebase/split existing commits; ask
  whether to accept the batched history, create follow-up corrective commits where
  possible, or reset/rework the step.
- Build the prompt from `references/step-review-prompt.md` (embed `git log --oneline`,
  `--stat`, and the diff per the template's size rule) and run `"$FRESH_REVIEW"` with
  the configured engine, saving to `plans/reviews/<plan-slug>-step-NN-review-<ts>.md`.
- Run **Triage**. For accepted findings: continue the same step child using the
  runtime's continuation primitive and ask it to fix all accepted findings from that
  review in one focused review-fix commit, unless the accepted findings are unrelated
  enough that one commit would violate the commit-message skill's "one logical change"
  rule. The fix commit must use the commit-message reference when available, and its
  subject/body must describe the code change itself, not the step number, finding
  number, or pipeline bookkeeping. Re-run validation; no second cross-review unless the
  user asks.

### 4. Close the step

- Mark the step done in the plan body (checkbox or `✅` on the step heading).
- Append to `## Execution Log`:

```markdown
### Step NN — <title> (<yyyy-MM-dd>)
- Commits: <START_SHA>..<END_SHA> (<n> commits)
- Done: <2-4 bullets of what was delivered>
- Decisions/contracts: <anything later steps must respect — or omit>
- Review: <review file> — accepted X, discarded Y
- Substep commits: <substep title> → <commit sha> (repeat for each planned substep)
```

- The orchestrator is the ONLY writer of the plan file and the log.
- Increment `steps_completed_this_run`. If `max_steps` is set and the invocation has
  reached it while unfinished steps remain, keep `phase: execute`, report the next
  unfinished step, and stop without asking to continue.
- `substep`/`step` modes: ask the user "continue with step NN+1?" before looping.
  `full`: loop directly.

### Phase: done

When no steps remain: set `phase: done`, give a final summary (steps, commit count,
review files, open minor findings never integrated). Do not set `phase: done` merely
because `max_steps` was reached; that is a clean pause, not completion.

## Triage

Classify each finding as `blocking` / `major` / `minor` (trust the reviewer's severity
unless clearly wrong — say so when overriding) and add your own one-line recommendation
(integrate / discard + why).

- `interactive`: first show the full classified list as an overview (numbered, with
  severity only — no recommendations yet). Then walk the findings ONE BY ONE, in
  severity order. For each finding:
  1. Present it NEUTRALLY: the issue, its evidence, and a **concrete application
     case** — a specific scenario from this repository showing how the issue would
     bite (if the review didn't provide one, build one from the codebase). Then the
     resolution options (a/b/c) with their trade-offs. Do NOT reveal the reviewer's
     `Preferred:` line nor your own preference at this stage; answer questions and
     discuss the options until the user picks one (or proposes their own variant, or
     discards).
  2. AFTER the user picks: reveal whether their choice matches the reviewer's
     preference and your own. If it matches, confirm and move on. If not, say which
     option you/the reviewer would have taken and why, and let the user keep or
     switch — their final word wins.
  3. Apply the resulting plan edit immediately, before moving to the next finding,
     so each decision is visible in the plan and later findings can be re-evaluated
     against it (mark any finding made obsolete by a previous decision and say so).
  Batch shortcuts remain available anytime ("apply the preferred option for all
  remaining", "discard all minors") — offer them upfront for `minor` findings to
  keep the one-by-one loop focused on `blocking`/`major`.
- `auto`: integrate `blocking` + `major` using the reviewer's `Preferred:` option
  (override it only if it's clearly wrong, and log the override); record discarded
  findings with reasons in the execution log entry.
- `raw`: print the review verbatim, wait for instructions.

## Runtime compatibility

This skill is intentionally dual-runtime:

- Claude Code uses Agent/SendMessage when available.
- Pi uses the `subagent` tool (`worker` with `context: "fresh"`, then `resume` for the
  same run id) when available.
- If neither primitive exists, execute the step inline in the current session.
- AskUserQuestion or Pi's `interview` may be used for structured checkpoints; otherwise
  ask plain numbered questions and wait.
- `fresh-review` only needs bash and works everywhere.

## Error handling

- Engine CLI fails or returns empty → show stderr, propose retry or switching engine
  (frontmatter override), don't mark the phase complete.
- Step agent dies mid-step → uncommitted work may remain; show `git status`, let the
  user decide (reset vs keep), then respawn the step agent with a note about the
  partial state.
- Worktree dirty at step start with files unrelated to the plan → warn before
  spawning; never let a step agent commit pre-existing changes.
- Plan steps unparseable → propose an inferred step structure and confirm before
  writing anything.
