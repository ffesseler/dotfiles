---
name: plan-executor
description: Execute high-level implementation plans step by step with detailed planning, user validation, and progress tracking. Use when the user wants to (1) implement a plan file (for example "execute plan.md"), (2) continue interrupted plan execution ("continue", "resume", "next step"), (3) review a step-by-step plan before coding, or (4) adjust scope during execution.
disable-model-invocation: true
---

# Plan Executor

Execute a high-level plan one step at a time. Propose implementation details before coding, implement only after user approval, and require user validation before marking steps or substeps complete.

## Workflow

Follow this cycle for each step:

1. Import plan
2. Select next step
3. Propose detailed plan (include substep breakdown for broad steps)
4. Implement
5. Validate with user
6. Mark complete
7. Repeat until all steps are done

## Planning Backend Compatibility

Use whichever task-tracking primitives are available in the runtime.

- Preferred: `TaskCreate`, `TaskList`, `TaskUpdate` (and `TaskGet` if available)
- Fallback: `update_plan` with one item per plan step and statuses `pending` / `in_progress` / `completed`

If neither is available, track state explicitly in conversation and keep exactly one active item (step or substep).

## Start New Plan Execution

When the user provides a plan file:

1. Read the file.
2. Parse steps using this order:
   - Headings like `Step 1:` / `Step 1 -` / `## Step 1`
   - Numbered sections where each number is a step (`1.` `2.` `3.`)
   - If still ambiguous, propose inferred steps and ask for confirmation before creating tasks
3. For each step, create one task/plan item:
   - `subject`: step number + short title
   - `description`: objective + actions + expected result + validation
   - `activeForm`: present continuous phrase when supported
4. Report number of steps imported.
5. Move to Select Next Step.

## Resume Interrupted Work

When the user says "continue", "resume", "next step", or similar:

1. List current tasks/plan items.
2. If one is `in_progress`, ask whether to continue it or mark it complete.
3. If none are `in_progress`, choose next `pending` item (prioritize substeps of the current parent step when present).
4. If no pending steps remain, confirm whether the plan is finished.

## Select Next Step

1. List tasks.
2. If the current parent step has pending substeps, choose the next pending substep.
3. Otherwise choose next `pending` top-level step that is not blocked.
4. Mark it `in_progress`.
5. If the item is a top-level step, read the plan-level `## Next step context` section when present and use it to speed up context gathering.
6. Announce current item start.
7. If the item is a top-level step, move to Propose Detailed Plan.
8. If the item is a substep, move directly to Implement.

## Propose Detailed Plan

1. Read `references/detailed-planning.md`.
2. Read relevant code/files before planning.
3. Build a concrete plan with:
   - Objective
   - Exact files to create/modify/delete
   - Ordered implementation actions
   - Validation (automated checks + user-observable checks)
4. If the step spans multiple change areas, include a **substep breakdown** in the plan itself (see Create Substeps). The user reviews and approves the plan and its substep structure together.
5. Present the plan.
6. Ask: `Does this plan look good, or would you like adjustments?`
7. Wait for response.

Response handling:

- Approve (`ok`, `yes`, `looks good`, `proceed`, `go ahead`): implement.
- Adjust (`change X`, `add Y`): revise and re-propose.
- Defer (`skip this for now`): set status back to `pending`, then pick next step.

## Create Substeps (Mandatory for Broad Steps)

As part of the detailed plan proposal (before user approval):

1. Assess the **breadth of changes**, not just file count. If the step spans **multiple distinct change areas** (for example: SQL migration, repository, service/API/UI), you **must** include a substep breakdown in the detailed plan itself. Tests are not a separate change area: they belong to the implementation substep they validate. A step that touches 3 files but crosses SQL → repo → service is too broad; a step that touches 6 files to add a field to DTOs is fine.
2. Group actions into substeps that are **coherent and independently testable**. Each substep should leave the codebase in a valid, runnable state.
3. Use the same status lifecycle as top-level steps: `pending` -> `in_progress` -> `completed`.
4. Name substeps with the parent prefix (for example `Step 2.1`, `Step 2.2`).
5. Keep exactly one active item (`in_progress`) at any time across steps and substeps.
6. Do not create a new detailed plan for each substep. Substeps execute directly from the parent step's approved detailed plan.
7. The user approves **both** the detailed plan and the substep breakdown in one go. Do not defer the substep proposal to after approval.

### When to Create Substeps

Create substeps when a step has **more than ~2 distinct change areas**. Common signals:

- SQL migration + application code
- Schema/data changes + type generation
- Backend + frontend
- Library code + consumer integration
- Multiple independent domain concepts added at once

Do NOT create substeps for steps that are one coherent change, even if many files are touched (e.g., renaming a symbol across 10 files).

### Substep Cohesion Rules

Substeps must group related changes so each unit is meaningful and testable on its own:

- **Keep tests with their implementation.** If a substep adds a function, component, endpoint, mapper, schema, prompt, or behavior, include the tests that verify it in the same substep — never defer tests to a later substep.
- **Never create a test-writing-only substep.** A substep named “Tests”, “Targeted tests”, “Tests ciblés”, or similar is invalid if it creates or edits tests for behavior implemented in previous substeps. Move each test into the substep that introduces the behavior it verifies.
- **Keep final validation separate from test authoring.** A final validation substep is allowed only to run existing/just-added checks across the completed increment. It must not add missing tests for previous substeps.
- **Keep type generation with the step that needs it.** If a step involves a migration and a generated type, keep both in the same substep. Do not split "run migration" from "regenerate types".
- **Keep a UI change with its supporting logic.** If a new screen requires a new hook, group the hook and the screen in the same substep.
- **Keep related config changes together.** If a feature needs route registration and layout changes, group them.
- **It is OK to split by domain boundary.** For example, if a step touches both an API layer and a UI layer, and the API work is self-contained and testable independently, that can be a separate substep.

### Substep Breakdown Pattern

Use a **layer-by-layer** progression, keeping each layer testable before moving to the next:

```
7.1 — Schema/data layer + generated artifacts
     Migration + type generation + local DB validation

7.2 — Data access layer + its tests
     Repository mapping + repository tests

7.3 — Business/service layer + its tests
     Service logic + service tests

7.4 — Final validation
     Combined targeted tests + type-check + plan update
```

Each substep builds on the previous one and is independently testable. The final substep is a cross-layer validation that confirms everything works together.

### Substep Proposal Self-Check

Before presenting a detailed plan with substeps, verify:

- [ ] No substep is primarily “write tests”.
- [ ] Every behavior-changing substep lists its implementation files and its test files together.
- [ ] Any final validation substep only runs checks; it does not create or edit tests.
- [ ] If a proposed test covers behavior from Step N.M, that test is included in Step N.M.

### Good Substep Splits

| Too Fine ❌ | Coherent ✅ |
|---|---|
| Step 2.1: Add `useAuth` hook | Step 2.1: Add `useAuth` hook + its unit tests |
| Step 2.2: Write tests for `useAuth` | Step 2.2: Wire `useAuth` into LoginScreen + integration test |
| Step 3.1: Run database migration | Step 3.1: Run migration + regenerate types + verify generated output |
| Step 3.2: Regenerate types | Step 3.2: Build API endpoints using new types + endpoint tests |
| Step 4.1: Create component file | Step 4.1: Create component + its stories/tests |
| Step 4.2: Add component styles | Step 4.2: Integrate component into parent screen |
| Step 1.2: Domain + persistence + DTOs<br>Step 1.3: Targeted tests | Step 1.2: Domain + persistence + DTOs + mapper/service tests<br>Step 1.3: Final validation only |

### Bad Substep Splits (Avoid)

- Separating interface/types from their consumers
- Putting a bug fix in one substep and its regression test in another
- Splitting a single React component across substeps (e.g., props in one, rendering in another)
- Isolating imports/exports as their own substep

## Implement

1. Execute the approved detailed plan.
2. If substeps exist, execute one substep at a time in order.
3. Follow existing project patterns.
4. Keep updates short and progress-oriented.
5. When implementation is complete for the current item (step or substep), move to Validate.

## Validate

1. Announce implementation completion for the current item (step or substep).
2. Summarize changed files and key behavior changes.
3. Run automated checks when available (for example targeted tests, lint, build/typecheck).
4. Provide user validation steps.
5. Ask user to validate or request adjustments.

Response handling:

- Approve (`validated`, `done`, `next`): mark complete.
- Adjust: implement requested changes, then re-validate.
- Test first (`let me test`): wait, then continue from their response.

## Mark Complete

1. Set current item status to `completed`.
2. If current item is a substep, continue with the next pending substep under the same parent step.
3. If all substeps for a parent step are completed, confirm parent-step completion with the user, then set parent step to `completed`.
4. Check remaining top-level steps.
5. If steps remain, ask whether to continue now.
6. If none remain, announce completion and exit.

## Mandatory Plan Progress Log

When a plan file is writable, the plan file itself is the durable execution record.
Do not rely only on task state or conversation history.

### When to Update

- After the user validates a completed substep: update its parent step's in-progress log entry.
- After the user validates a completed top-level step: update the checklist and write/finalize its completion entry **before** reporting the step as marked complete.
- While finalizing a completed step, update the plan-level `## Next step context` section with concise context that will help a fresh session start the next pending step.
- Before starting the next top-level step: read the most recent progress entry to recover delivered scope, deferred work, and plan changes; also read `## Next step context` when present.

If the plan has no `## Progress log` section, create one at the end of the existing plan. This is an explicit exception to the usual “do not create docs” rule: the user asked to execute the plan, and the plan is the execution state.

### Required Entry Structure

Every completed top-level step gets an entry in this exact structure:

```md
### YYYY-MM-DD — Step N completed

#### Delivered
- Implemented behavior, key files/components, and user-visible result.

#### Deferred
- Work intentionally moved to a later step, omitted from scope, or still blocked.

#### Plan changes
- Every decision that differs from the initial plan: changed behavior, renamed/replaced component, moved increment, relaxed/tightened contract, or new dependency.
- Write `None.` only when there were no deviations.
```

Be explicit rather than silently rewriting history. A change from “generate on the first exploitable message” to “always ask first” is a **Plan changes** item, not an implementation detail. A feature intentionally postponed to a later step is a **Deferred** item, even if it was mentioned elsewhere in the plan.

### Next Step Context

Keep a single plan-level `## Next step context` section for handoff context. Do not add next-step context to every completed step entry.

Use it only to help the next fresh execution context start faster:

- code pointers and relevant symbols;
- existing patterns to follow;
- constraints or facts discovered while the completed step was still loaded in context;
- scope notes that affect the next pending step.

Keep it factual and concise. Do not write a detailed plan for the next step. Replace stale context instead of appending indefinitely. If there is no useful context to carry forward, write `None.`

**Completion gate:** updating this log and the plan checklist is mandatory. Do not state that a step is complete until both are saved successfully.

## Error Handling

Handle failure modes explicitly:

1. Plan file missing/unreadable: ask for corrected path and stop execution flow.
2. Plan has no parseable steps: provide proposed structure and ask user to confirm before continuing.
3. Duplicate import risk (tasks already exist): ask whether to reuse existing tasks or recreate from scratch.
4. Multiple `in_progress` steps found: ask user which one to keep active, set others to `pending`.
5. Substep drift (substeps exist but parent is not `in_progress`): restore parent to `in_progress` before continuing.

## State Model

Canonical states:

- Plan Loaded
- Tasks Created
- Step Selected
- Plan Proposed
- Plan Revised
- Substep Selected
- Implementing
- Substep Implementing
- Step Done
- Substep Done
- Adjusting
- Marked Complete
- Plan Complete
- Resume Flow

See `references/workflow-states.md` for transitions.

## Best Practices

### Read Before Writing

Read related files before detailing implementation.

### Follow Existing Patterns

Match structure, naming, imports, and style already present in the codebase.

### Keep One Active Step

Only one item (step or substep) should be `in_progress` at a time.

### Require User Validation

Do not mark a step or substep complete without explicit user confirmation.

### Communicate Concisely

Report what changed, what was validated, and what decision is needed next.

## Anti-Patterns

### Skipping Plan Approval

- Bad: start coding without approval of the detailed plan.
- Good: get explicit approval before implementation.

### Skipping Validation

- Bad: move to next step immediately after coding.
- Good: validate (automated + user confirmation) before completion.

### Creating Substep Plans

- Bad: create a new detailed plan for every substep.
- Good: use the parent step's approved detailed plan and execute substeps directly.

### Losing State

- Bad: change phase without updating task status.
- Good: keep status aligned with workflow state.

### Vague Detail Plans

- Bad: "update component".
- Good: specify file, concrete change, and validation.

### Deferring Substep Breakdown After Approval

- Bad: present the detailed plan, get approval, then say "I'll split this into substeps now."
- Good: include the substep breakdown in the plan proposal so the user approves both together.

### Splitting Tests From Implementation

- Bad: Substep A adds `useAuth` hook, Substep B adds its tests.
- Good: One substep includes both the hook and its tests.

### Splitting Generated Artifacts From Their Triggers

- Bad: Substep A runs a migration, Substep B regenerates types from it.
- Good: One substep runs the migration, regenerates types, and verifies the generated output.

## See Also

- `references/workflow-states.md` - state machine and transitions
- `references/task-management.md` - task API usage and fallback mapping
- `references/detailed-planning.md` - detailed plan template and quality checklist
