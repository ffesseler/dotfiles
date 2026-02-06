# Workflow States

The plan-executor follows a state machine for each step execution.

Task state can be tracked with `TaskCreate`/`TaskList`/`TaskUpdate` or, when unavailable, with `update_plan` statuses.
Substeps use the same status lifecycle but skip the detailed-plan proposal phase.

## State Diagram

```
[Plan Loaded]
     │
     ├─(Create Tasks)──> [Tasks Created]
     │                         │
     │                         ├─(Get Next)──> [Step Selected]
     │                         │                      │
     │                         │                      ├─(Detail Plan)──> [Plan Proposed]
     │                         │                      │                       │
     │                         │                      │                       ├─(User Approves)──> [Implementing]
     │                         │                      │                       │                          │
     │                         │                      │                       │                          ├─(Complete)──> [Step Done]
     │                         │                      │                       │                          │                    │
     │                         │                      │                       │                          │                    ├─(User Validates)──> [Marked Complete]
     │                         │                      │                       │                          │                    │                            │
     │                         │                      │                       │                          │                    │                            └─(Loop)─────┐
     │                         │                      │                       │                          │                    │                                         │
     │                         │                      │                       │                          │                    └─(User Requests Changes)──> [Adjusting]  │
     │                         │                      │                       │                          │                                                      │        │
     │                         │                      │                       │                          │                                                      └───────┘│
     │                         │                      │                       │                          │                                                              │
     │                         │                      │                       │                          └─(User Requests Changes)──────────────────────────────────────┘
     │                         │                      │                       │
     │                         │                      │                       └─(User Adjusts Plan)─────> [Plan Revised]
     │                         │                      │                                                         │
     │                         │                      │                                                         └──────────────────┐
     │                         │                      │                                                                            │
     │                         │                      └────────────────────────────────────────────────────────────────────────────┘
     │                         │
     │                         └─(All Done)──> [Plan Complete]
     │
     └─(Resume)──> [Resume Flow]
```

## States Explained

### Plan Loaded
Initial state after user provides a plan file. Agent reads the high-level plan.

### Tasks Created
Tasks imported from plan using TaskCreate (or mapped as `update_plan` items). One task/plan item per step.

### Step Selected
Next pending step identified using TaskList (or current plan). Step marked as `in_progress`.

### Plan Proposed
Detailed implementation plan for the step created and presented to user for approval.

### Plan Revised
User requested changes to the detailed plan. Agent adjusts and re-proposes.

### Substep Selected
Next pending substep of the current parent step is selected and marked `in_progress`.

### Implementing
User approved the detailed plan. Agent executes the implementation.

### Substep Implementing
Agent executes substep actions directly from the parent step's approved detailed plan.

### Step Done
Implementation complete. Agent asks user to validate or request adjustments.

### Substep Done
Substep implementation complete. Agent asks user to validate or request adjustments.

### Adjusting
User requested changes after implementation. Agent makes adjustments and re-validates.

### Marked Complete
User validated the current step or substep. Current task/plan item marked as `completed`. Agent asks to continue or stop.

### Plan Complete
All tasks are completed. Agent reports success.

### Resume Flow
User resumes an interrupted plan. Agent checks task status and continues from appropriate state.

## Transitions

- **User Approves**: User says "ok", "yes", "looks good", "proceed", "go ahead"
- **User Adjusts Plan**: User requests changes to detailed plan before implementation
- **User Requests Changes**: User requests changes after implementation
- **User Validates**: User confirms current step or substep is complete
- **Loop**: Return to "Get Next" to continue with next task or substep
- **Complete**: Current implementation is finished
- **All Done**: No more pending tasks
- **Resume**: User asks to continue an existing plan
