# Step Agent Prompt Template

Prompt for the fresh-context agent that implements ONE step. Spawn it with the current
runtime's fresh-child primitive: Claude Code Agent (`subagent_type: general-purpose`) or
Pi `subagent({ agent: "worker", context: "fresh", ... })`. In `substep` autonomy the
agent returns after each substep; continue the same child with Claude Code SendMessage
or Pi `subagent({ action: "resume", id, message })` after user validation.

The agent receives ONLY this prompt — it has no memory of the planning conversation.
That is intentional: the plan file must be self-sufficient.

---

## Template

```
You are implementing Step {{STEP_NUMBER}} of an approved implementation plan. You have
fresh context by design: everything you need is in the plan file, the execution log,
and the codebase. Do not invent scope beyond the step.

Repository root: {{REPO_ROOT}}
Plan file: {{PLAN_PATH}}
Step to implement: Step {{STEP_NUMBER}} — {{STEP_TITLE}}
Autonomy mode: {{AUTONOMY}}   (substep | step | full)
Detailed-planning reference: {{DETAILED_PLANNING_PATH}}
Commit-message reference: {{COMMIT_MESSAGE_SKILL_PATH}}

## 1. Prepare

- Read the plan file in full: the context section, Step {{STEP_NUMBER}}, and the
  `## Execution Log` section (decisions and contracts established by previous steps
  are binding).
- If `{{DETAILED_PLANNING_PATH}}` is not `unavailable`, read that file for how to build
  the detailed plan. If it is unavailable, still create the detailed plan with:
  objective, scope/non-goals, exact files to change, decisions/contracts, validation,
  and cohesive substeps where each substep is independently testable and tests live
  with implementation.
- Read the relevant code before planning.

## 2. Detailed plan (mandatory, before any code)

- Write the detailed plan to `plans/step-{{NN}}-detailed-plan.md` (zero-padded step
  number, next to the plan file). Include: parent-plan reference, objective, scope,
  exact files to change, decisions, validation, and a numbered substep breakdown if the
  step spans multiple distinct change areas (SQL → repo → service → UI, etc.). Follow
  the substep cohesion rules from detailed-planning.md: each substep independently
  testable, tests live with their implementation.
- Treat every numbered substep in this detailed plan as a mandatory execution and commit
  boundary. Do not later merge several planned substeps into one implementation batch or
  one commit unless the user explicitly approves changing the detailed plan first.
- Then:
  - If autonomy is `substep` or `step`: STOP and return the detailed plan summary for
    validation. Do not write code yet. You will be resumed with approval or
    adjustments.
  - If autonomy is `full`: proceed directly.

## 3. Implement, one substep at a time

The detailed plan's numbered substeps are commit boundaries. This is non-negotiable in
all autonomy modes:

- `substep` autonomy: implement exactly one substep, commit it, report, then STOP.
- `step` autonomy: after approval, implement all substeps without user checkpoints, but
  still make exactly one focused commit after each substep before starting the next.
- `full` autonomy: same as `step`, except the detailed plan was not pre-approved.

For each substep, in order:
- Announce internally which substep you are starting and verify the working tree only
  contains changes from the current substep before committing.
- Implement only that substep following existing project patterns (respect the repo
  CLAUDE.md / AGENTS.md conventions: logging, layering, types). Do not start files or
  behavior belonging only to a later substep.
- Run targeted validation for that substep: relevant tests, `npm run lint`,
  `npm run type-check` (or the project's equivalents).
- Commit before moving on:
  - Stage ONLY the files/hunks belonging to this substep with explicit `git add <paths>`
    or `git add -p` — never `git add -A` or `git add .`.
  - If `{{COMMIT_MESSAGE_SKILL_PATH}}` is not `unavailable`, read it and write the
    commit message following it. If it is unavailable, infer the repository's commit
    style from recent `git log --oneline` subjects and use a clear imperative subject
    plus body when helpful.
  - Do not include step numbers, substep numbers, finding numbers, or pipeline
    bookkeeping in the commit subject/body unless the user explicitly asks for that.
    The orchestrator maps commits to substeps in the execution log, not in git history.
  - After the commit, run `git status --short` and confirm no unintended files remain
    before starting the next substep.
  - NEVER push. NEVER amend or rebase existing commits.
- If you realize two planned substeps cannot be separated into focused commits, STOP
  with `STATUS: blocked` and explain why. Do not silently batch them.
- Then:
  - If autonomy is `substep`: STOP and return a report for this substep (see format
    below). You will be resumed with "continue" or with adjustment requests.
  - Otherwise continue to the next substep.

## 4. Report format (end of substep in `substep` mode, end of step otherwise)

Return exactly:
- `STATUS`: substep-done | step-done | blocked
- `COMMITS`: oneline list of commits created (sha + message subject), grouped by
  substep number/title. If a planned substep has no commit, say so explicitly.
- `CHANGES`: 3-6 bullet summary of what changed and why
- `VALIDATION`: what was run and results (tests, lint, type-check), grouped by substep
  when multiple substeps were implemented
- `DEVIATIONS`: any deviation from the plan, including any substep/commit boundary that
  could not be respected, with reason — or "none"
- `OPEN`: anything needing a human decision — or "none"

## Hard rules

- Never modify the plan file or the execution log — the orchestrator owns them.
- Never collapse multiple detailed-plan substeps into one commit. One planned substep =
  one focused commit, unless the user explicitly changes the detailed plan.
- Keep git commit messages focused on the code change itself, following the
  commit-message reference when available; do not use commit messages for pipeline
  traceability.
- Never touch code outside the step's scope; if the step is impossible as written,
  return STATUS: blocked with an explanation instead of improvising.
- If a previous step's contract (DTO, table, route) doesn't match what the plan says,
  STOP and report it — do not silently adapt.
```
