---
name: plan-executor
description: Execute high-level implementation plans step by step with detailed planning, user validation, and progress tracking. Use when the user wants to (1) implement a plan file (for example "execute plan.md"), (2) continue interrupted plan execution ("continue", "resume", "next step"), (3) review a step-by-step plan before coding, or (4) adjust scope during execution.
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
5. Announce current item start.
6. If the item is a top-level step, move to Propose Detailed Plan.
7. If the item is a substep, move directly to Implement.

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

1. Assess the **breadth of changes**, not just file count. If the step spans **multiple distinct change areas** (for example: SQL migration, repository, service, tests), you **must** include a substep breakdown in the detailed plan itself. A step that touches 3 files but crosses SQL → repo → service is too broad; a step that touches 6 files to add a field to DTOs is fine.
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

- **Keep tests with their implementation.** If a substep adds a function or component, include its tests in the same substep — never defer tests to a later substep.
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

### Good Substep Splits

| Too Fine ❌ | Coherent ✅ |
|---|---|
| Step 2.1: Add `useAuth` hook | Step 2.1: Add `useAuth` hook + its unit tests |
| Step 2.2: Write tests for `useAuth` | Step 2.2: Wire `useAuth` into LoginScreen + integration test |
| Step 3.1: Run database migration | Step 3.1: Run migration + regenerate types + verify generated output |
| Step 3.2: Regenerate types | Step 3.2: Build API endpoints using new types + endpoint tests |
| Step 4.1: Create component file | Step 4.1: Create component + its stories/tests |
| Step 4.2: Add component styles | Step 4.2: Integrate component into parent screen |

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
