---
name: high-level-planner
description: Create concise implementation plans organized by functional increments for software development tasks. Use when the user asks for a plan, roadmap, execution strategy, or phased approach before coding. Avoid using this skill for trivial one-shot edits or when the user explicitly wants immediate implementation instead of planning.
---

# High-Level Planner

Create implementation plans organized by functional increments rather than technical layers. Each increment should deliver testable user value.

## Core Principles

### Functional Increments Over Technical Layers

Avoid technical organization:
```
Step 1: Create database schema
Step 2: Create API endpoints
Step 3: Create UI components
```

Prefer functional increments:
```
Step 1: User can view list (backend + frontend + data)
Step 2: User can filter list (search logic + UI)
Step 3: User can edit items (modal + API + validation)
```

Each step delivers a testable feature the user can try.

### Keep Plans Concise

Plans should be scannable and lightweight:
- Focus on WHAT needs to be done, not HOW to implement
- Save implementation details for later (when executing each step)
- Use bullet points, not paragraphs
- Target 1-2 short sentences plus 3-5 bullets per step
- Keep the full plan concise for fast review and iteration

### Plan Structure

Each functional increment should include:

1. Objective - What user capability this enables (1 sentence)
2. Actions - High-level tasks to accomplish (3-5 bullets max)
3. Result - Observable outcome the user can verify (1 sentence)
4. Validation - Quick check to confirm the increment is done (1 sentence)

Example:
```markdown
### Step 2: User Can Filter List

**Objective**: Enable users to search items by name and category

**Actions**:
- Add search state to component
- Filter data based on search query
- Update UI to show filtered results

**Result**: User can type in search box and see matching items

**Validation**: Entering "wire" only shows items with "wire" in name/category
```

## Plan Format

### Required Sections

1. Overview - Brief context (2-3 sentences)
2. Functional Increments - Numbered steps with Objective/Actions/Result/Validation
3. Key Decisions - Important choices made during planning
4. Checklist - Summary of all steps

## Output Behavior

By default, write the plan to a Markdown file in the workspace.

- Default path: `plan-<YYYYMMDD-HHMMSS>.md` (or `plans/<topic>-<YYYYMMDD-HHMMSS>.md` when context is clear)
- Accept optional output path/name from user (for example: `output_path=plans/auth-refactor.md` or "save as plans/auth-refactor.md")
- Ensure `.md` extension and workspace-relative path
- If target file exists, ask before overwriting unless the user requested overwrite
- If the user asks for chat-only output, skip file creation
- After writing the file, provide a short chat summary and include the file path

### Optional Sections

Include when useful for the specific task:
- Diagrams - For complex flows, cross-system interactions, or non-obvious architecture
- API Contract - For new endpoints or integrations
- Edge Cases - For critical scenarios to handle
- Failure Modes & Recovery - For expected failures and fallback behavior
- Migration Path - For refactoring or breaking changes

## Optional Section Templates

Use these compact templates when needed.

### API Contract

```markdown
## API Contract

- Endpoint: `POST /supplies`
- Request: `{ name, unitCost, margin? }`
- Response: `{ id, name, computedPrice }`
- Errors: `400 validation_error`, `409 duplicate_name`
```

### Edge Cases

```markdown
## Edge Cases

- Empty data set: Show empty state and CTA
- Slow network: Show loading state and retry action
- Invalid inputs: Display field-level errors
```

### Failure Modes & Recovery

```markdown
## Failure Modes & Recovery

- Failure: Supply create API times out
- User Impact: Save action appears stuck
- Recovery: Show retry action and keep form state intact
```

### Migration Path

```markdown
## Migration Path

- Phase 1: Ship behind feature flag
- Phase 2: Backfill required data
- Phase 3: Remove deprecated route and UI branch
```

## Diagrams

Use ASCII diagrams when they improve clarity. Keep them simple and focused. Choose diagram types based on what needs to be communicated.

### When to Use Each Diagram Type

User Flow - For interactive features with multiple steps
```
┌─────────────────────────────────┐
│ User clicks "Add Item" button   │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Modal opens with empty form     │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ Item added + modal closes        │
└─────────────────────────────────┘
```

Component/Module Structure - For new screens or major refactors
```
BaseScreen
├── Header
│   ├── Title
│   ├── SearchBar
│   └── CreateButton
├── Tabs
│   ├── ServicesTab (existing)
│   └── SuppliesTab (new)
└── Modal
```

Data Flow - For transformations or processing pipelines
```
Raw Input → Validate → Transform → Persist → Notify
```

Sequence Diagram - For multi-system interactions
```
User        App         API         Database
  │          │           │             │
  ├─click───>│           │             │
  │          ├─request──>│             │
  │          │           ├─query──────>│
  │          │           │<────result──┤
  │          │<──data────┤             │
  │<─update──┤           │             │
```

Architecture Diagram - For new services or major components
```
┌──────────────┐
│  Frontend    │
└──────┬───────┘
       │ HTTP
       ▼
┌──────────────┐     ┌──────────────┐
│   API        │────>│  Database    │
└──────┬───────┘     └──────────────┘
       │
       ▼
┌──────────────┐
│ External API │
└──────────────┘
```

State Machine - For complex state transitions
```
[Draft] ──validate──> [Ready] ──submit──> [Processing]
   │                     │                     │
   └───────edit──────────┘                     ▼
                                          [Complete]
```

Use 0-2 diagrams in most plans. Only include diagrams that reduce ambiguity.

## Key Decisions Section

Document important choices made while planning:

```markdown
## Key Decisions

### Form Simplification
**Decision**: Remove "quantity" field from UI
**Reason**: Always defaults to 1 in current scope
**Impact**: Simpler UX, fewer validation errors

### Search Location
**Decision**: Search bar above tabs (shared)
**Reason**: Single search filters active tab content
**Alternative considered**: Separate search per tab (more complex)
```

Keep this section small. Include only decisions that materially affect scope, UX, or delivery risk.

## Checklist Format

Provide a scannable summary:

```markdown
## Checklist

- [ ] Step 1: Setup base screen structure
- [ ] Step 2: Display item list
- [ ] Step 3: Add search functionality
- [ ] Step 4: Implement edit modal
- [ ] Step 5: Add create functionality
```

## Plan Quality Gate

Before finalizing a plan, verify:
- Each increment is independently testable by a user
- Step order minimizes blocking dependencies
- Unknowns and notable risks are called out in decisions or edge cases
- Critical failure paths include fallback or retry behavior
- The plan is concise enough to execute without re-reading large prose

## Anti-Patterns

### Too Much Detail

Don't include implementation code in high-level plans:
```markdown
**Action**: Create useState hook for search query
```

Instead:
```markdown
**Action**: Add search state management
```

### Technical-First Organization

Don't organize by technology layer:
```markdown
Step 1: Database Schema
Step 2: API Endpoints
Step 3: React Components
```

Instead, organize by user capability:
```markdown
Step 1: User can view items (includes DB, API, UI)
Step 2: User can search items
```

### Overly Verbose Explanations

Don't write paragraphs:
```markdown
The first step involves creating a comprehensive database schema
that will support all the fields we need. This schema should include
proper indexing and relationships...
```

Instead, be concise:
```markdown
**Action**: Create database schema with required fields
```

## Workflow

1. **Understand requirements** - Ask clarifying questions if needed
2. **Identify functional increments** - What can user test at each step?
3. **Add diagrams when needed** - Visualize complex flows only
4. **Document decisions** - Capture important choices made
5. **Create checklist** - Summary for quick reference
6. **Run quality gate** - Ensure increments are testable and plan is executable
7. **Iterate with user** - Refine plan before implementation

## Example Plan

See [EXAMPLE.md](references/EXAMPLE.md) for a complete plan following this format.
