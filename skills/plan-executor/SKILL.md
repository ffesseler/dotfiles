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
3. Propose detailed plan
4. Create substeps if useful
5. Implement
6. Validate with user
7. Mark complete
8. Repeat until all steps are done

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
4. Present the plan.
5. Ask: `Does this plan look good, or would you like adjustments?`
6. Wait for response.

Response handling:

- Approve (`ok`, `yes`, `looks good`, `proceed`, `go ahead`): implement.
- Adjust (`change X`, `add Y`): revise and re-propose.
- Defer (`skip this for now`): set status back to `pending`, then pick next step.

## Create Substeps (Optional)

After the user approves the detailed plan for a step:

1. If the step has multiple concrete actions, create substeps to track execution.
2. Use the same status lifecycle as top-level steps: `pending` -> `in_progress` -> `completed`.
3. Name substeps with the parent prefix (for example `Step 2.1`, `Step 2.2`).
4. Keep exactly one active item (`in_progress`) at any time across steps and substeps.
5. Do not create a new detailed plan for each substep. Substeps execute directly from the parent step's approved detailed plan.

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

## See Also

- `references/workflow-states.md` - state machine and transitions
- `references/task-management.md` - task API usage and fallback mapping
- `references/detailed-planning.md` - detailed plan template and quality checklist
