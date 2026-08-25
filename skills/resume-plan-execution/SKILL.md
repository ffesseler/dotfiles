---
name: resume-plan-execution
description: Resume an interrupted plan-executor run from its exact recorded checkpoint when the current step already has a detailed plan and the previous context is exhausted. Use when the user provides both the high-level plan, whose progress log records the current substep, and the existing detailed step plan. Preserve plan-executor's mandatory one-substep-at-a-time implementation and user-validation gates.
---

# Resume Plan Execution

## Arguments

Expect exactly two references, in this order:

```text
/skill:resume-plan-execution <high-level-plan> <detailed-step-plan>
```

If either reference is missing or unreadable, ask only for the missing reference.

## Required source workflow

Before acting, read the sibling skill `../plan-executor/SKILL.md` completely and follow its execution, validation, state, and progress-log rules. This is mandatory, not conditional. If the sibling cannot be read, try `~/.agents/skills/plan-executor/SKILL.md`; if neither location is readable, stop and ask for the `plan-executor` skill location.

## Resume workflow

1. Read both supplied plans completely. Treat the high-level plan's progress log as the durable checkpoint and the detailed plan as the approved specification for the current step.
2. Read the repository instructions governing the affected files, then inspect the worktree and relevant diffs so partially completed work is preserved.
3. Reconstruct the exact state: current parent step, current substep, whether its detailed plan is approved, what is already implemented, and what validation or user decision is still pending.
4. Resume that state directly. Do not regenerate either plan, restart the parent step, or repeat completed work merely to rebuild context.

## One-substep-at-a-time gate

For a detailed plan containing substeps:

1. Keep exactly one substep `in_progress`.
2. Work only on that substep. Do not edit files or perform actions assigned exclusively to a later substep.
3. Complete its implementation, tests, and its listed substep validation.
4. Summarize the result and ask the user to validate or request adjustments.
5. Stop and wait. Do not begin the next substep in the same turn.
6. Only after explicit user validation, mark the substep completed and update the high-level progress log using its existing format. The next substep may then start.

If the checkpoint is awaiting detailed-plan approval or user validation, resume at that gate and wait; invocation of this resume skill is not itself approval.

When repository evidence and the progress log differ, preserve valid work and record the reconciled state. Ask one focused question only if the safe resume point cannot be determined.
