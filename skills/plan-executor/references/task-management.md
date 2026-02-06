# Task Management Guide

This guide covers using TaskCreate, TaskUpdate, and TaskList for tracking plan execution progress, with a fallback mapping to `update_plan`.

## Creating Tasks from Plan

When importing a high-level plan, create one task per step:

```typescript
// For each step in the plan
await TaskCreate({
  subject: "Step 1: User can switch between tabs",
  description: "Enable navigation between Prestations and Fournitures sub-tabs...",
  activeForm: "Setting up tab navigation"
});
```

**Key points:**
- Use step number and title as subject
- Include full objective + actions in description
- Provide present continuous form for activeForm
- All tasks start as `pending` status

## Creating Substeps from an Approved Detailed Plan

When a step is approved and has multiple concrete actions, create substeps for execution tracking:

- Use parent-prefixed subjects (for example `Step 2.1: Create hook`, `Step 2.2: Wire UI`)
- Keep parent step `in_progress` while substeps are active
- Track each substep with the same statuses: `pending`, `in_progress`, `completed`
- Do not create separate detailed plans for substeps

## Checking Task Progress

Use TaskList to see all tasks and identify what to do next:

```typescript
const tasks = await TaskList();

// Find next task to work on
const nextTask = tasks.find(t =>
  t.status === 'pending' &&
  (!t.blockedBy || t.blockedBy.length === 0)
);

// Or find current in-progress task
const currentTask = tasks.find(t => t.status === 'in_progress');
```

Selection priority:

1. Pending substeps under the current `in_progress` parent step
2. Current `in_progress` top-level step (if no substeps remain)
3. Next pending top-level step

## Updating Task Status

### Mark task as in-progress when starting

```typescript
await TaskUpdate({
  taskId: "1",
  status: "in_progress"
});
```

### Mark task as completed when done

```typescript
await TaskUpdate({
  taskId: "1",
  status: "completed"
});
```

## Task States

- **pending**: Not started yet
- **in_progress**: Currently being worked on
- **completed**: Successfully finished

## Fallback: update_plan Mapping

If Task* APIs are unavailable in the runtime, map each step or substep to one `update_plan` item:

- `step`: Use the same value as task subject (for example `Step 1: Tab Navigation`)
- `status`: `pending` | `in_progress` | `completed`

Keep exactly one item (step or substep) `in_progress` at a time.

Example:

```typescript
await update_plan({
  plan: [
    { step: "Step 1: Tab Navigation", status: "completed" },
    { step: "Step 2: Supplies Hook", status: "in_progress" },
    { step: "Step 3: Supply List UI", status: "pending" }
  ]
});
```

## Best Practices

1. **One active item at a time**: Only one step or substep should be `in_progress` at any time
2. **Check before updating**: Re-list tasks (or current plan) before updating state
3. **Clean status**: Always mark tasks `completed` before moving to next
4. **Resume support**: Check for `in_progress` tasks when resuming work
5. **Substep discipline**: Execute and validate substeps directly from the approved parent-step detailed plan

## Example Workflow

```typescript
// 1. Import plan - Create all tasks
const plan = readPlan("plan.md");
plan.steps.forEach(step => {
  TaskCreate({
    subject: step.title,
    description: step.objective + "\n\n" + step.actions.join("\n"),
    activeForm: step.activeForm
  });
});

// 2. Get next task
const tasks = await TaskList();
const next = tasks.find(t => t.status === 'pending');

// 3. Mark as in-progress
await TaskUpdate({ taskId: next.id, status: 'in_progress' });

// 4. Implement the step...

// 5. Mark as completed
await TaskUpdate({ taskId: next.id, status: 'completed' });

// 6. Loop back to step 2
```
