---
name: high-level-planner
description: Create concise implementation plans organized by functional increments for software development tasks, with clear opening context and code pointers for the executor. Use when the user asks for a plan, roadmap, execution strategy, or phased approach before coding. Avoid using this skill for trivial one-shot edits or when the user explicitly wants immediate implementation instead of planning.
disable-model-invocation: true
---

# High-Level Planner

Create implementation plans organized by functional increments rather than technical layers. Each increment should deliver testable user value.

## Core Principles

### Start With Clear Context

Open every plan with enough context for a reader to understand the work without re-reading the whole conversation. The beginning of the plan should clearly answer:
- **Problem**: What is broken, missing, confusing, or limiting today?
- **Goal**: What user or system outcome are we trying to achieve?
- **Approach**: At a high level, what kind of change will solve it?
- **Scope**: What is intentionally included or excluded when that matters?

Keep this section concise, but make it concrete. Avoid vague openings like "Improve the feature"; name the affected workflow, the pain point, and the intended end state.

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

### Keep Docs Honest, Not Comprehensive

Don't create steps to write new functional documentation. Only flag doc updates when an increment makes existing docs obsolete or misleading.

Acceptable doc actions within an increment:
- Remove or update outdated sections in existing docs that the increment invalidates
- Update `AGENT.md` / `CLAUDE.md` instructions if the increment changes how the agent should behave or operate

Never add doc actions for:
- Writing new feature documentation
- Expanding or improving docs that are still accurate

### Tests Belong Inside Each Increment, Never Alone

Never create a dedicated "Write tests" or "Add test coverage" step. Tests are part of the increment they validate.

Avoid:
```
Step 3: User can edit items
Step 4: Write tests for edit flow  ← ❌ separate test step
```

Prefer:
```
Step 3: User can edit items (modal + API + validation + tests)  ← ✅ tests included
```

If an increment involves code, its tests are listed as actions within that same increment.

### Prefer Automated Validation

For code changes, validation should prioritize automated checks whenever they are realistic: unit tests, integration tests, type checks, linters, build commands, or targeted test commands. Manual validation is still useful, especially for UX flows, but it should usually complement automated checks rather than replace them.

When writing each increment's **Validation**, lead with the most relevant automated command or test expectation, then add a short manual smoke check if needed.

Prefer:
```markdown
**Validation**: Run `npm test -- saved-supply` and manually confirm creating a supply updates the list
```

Avoid relying only on manual validation when an automated check can cover the behavior:
```markdown
**Validation**: Click through the flow and confirm it works
```

### Keep Plans Concise

Plans should be scannable and lightweight:
- Focus on WHAT needs to be done, not HOW to implement
- Save implementation details for later (when executing each step)
- Use bullet points, not paragraphs
- Target 1-2 short sentences plus 3-5 bullets per step
- Keep the full plan concise for fast review and iteration

### Preserve Settled Technical Design

Filtering implementation detail must not erase an architectural solution that has already been discussed or agreed upon. Preserve the technical design decisions an executor needs in order to build the intended system rather than merely reproduce its visible behavior.

Capture constraints such as:
- Component or module boundaries and the role each one owns
- Shared interfaces, ports, normalized result shapes, and provider abstractions
- Where orchestration, selection policy, retries, persistence, billing, and error classification belong
- Important invariants across storage, security, privacy, observability, and timeout budgets
- Explicit technology or integration choices when they are part of the accepted design
- Naming or extension constraints that prevent the implementation from collapsing into an unintended structure

Do not expand these into class internals, pseudocode, method-by-method instructions, or incidental library options. State the boundary and its reason compactly. For example:

```markdown
## Technical Design Constraints

- `VoiceService` remains the orchestration boundary for storage, fallback, and usage accounting.
- Provider-specific clients implement one transcription contract and normalize their responses to `{ text, audioSeconds, model }`.
- A provider policy resolves the environment default and user override; controllers and clients do not select providers themselves.
- Provider clients classify format refusals, while the orchestrator owns the single retry.
- Log provider, model, latency, and fallback use, but never transcript contents.
```

If no technical design has been established, do not invent one merely to fill this section. If the conversation contains competing designs that remain unresolved, record the decision as open rather than silently choosing.

### Plan Structure

Before writing increments, include a short orientation section and code pointers so the future executor starts with the right mental model and the right files.

Each functional increment should include:

1. Objective - What user capability this enables (1 sentence)
2. Actions - High-level tasks to accomplish (3-5 bullets max)
3. Result - Observable outcome the user can verify (1 sentence)
4. Validation - Automated check first when possible, plus a manual smoke check if useful (1 sentence)

Example:
```markdown
### Step 2: User Can Filter List

**Objective**: Enable users to search items by name and category

**Actions**:
- Add search state to component
- Filter data based on search query
- Update UI to show filtered results

**Result**: User can type in search box and see matching items

**Validation**: Run the relevant filter tests and manually confirm entering "wire" only shows matching items
```

## Plan Format

### Required Sections

1. Overview - Clear problem/goal/approach context (2-5 concise bullets or sentences)
2. Code Pointers - Important files, modules, tests, and docs to inspect before executing
3. Technical Design Constraints - Include when the conversation or investigation established architectural boundaries, contracts, responsibilities, or invariants
4. Functional Increments - Numbered steps with Objective/Actions/Result/Validation
5. Key Decisions - Important choices made during planning
6. Checklist - Summary of all steps

### Overview Template

Use this shape unless a simpler paragraph is clearer:

```markdown
## Overview

- **Problem**: [What is not working, missing, or unclear today]
- **Goal**: [What outcome the change should produce]
- **Approach**: [High-level strategy, not implementation details]
- **Scope**: [Optional: boundaries, exclusions, or assumptions]
```

### Code Pointers Template

Include files that matter for execution, grouped by why they matter. Prefer concrete paths over generic areas. If you are unsure about a path, say so instead of inventing one.

```markdown
## Code Pointers

- `path/to/file.ts`: Existing behavior to modify or mirror
- `path/to/component.tsx`: UI entry point affected by the change
- `path/to/file.spec.ts`: Tests to update or use as examples
- `docs/relevant-doc.md`: Existing documentation that may become stale
```

Keep this section short: usually 4-8 pointers. Add a one-line reason for each pointer so the executor knows why it matters.

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
- The opening context clearly states the problem, desired outcome, and high-level approach
- Code Pointers names the most important files/tests/docs an executor should inspect first
- Settled architectural boundaries, shared contracts, responsibility ownership, and operational invariants from the discussion are preserved
- The plan removes low-level mechanics without reducing an agreed technical design to behavior alone
- Each increment prioritizes automated validation when realistic, with manual checks as a complement
- Each increment is independently testable by a user
- Step order minimizes blocking dependencies
- Unknowns and notable risks are called out in decisions or edge cases
- Critical failure paths include fallback or retry behavior
- The plan is concise enough to execute without re-reading large prose
- **No step is solely dedicated to writing tests** — tests are embedded in the increment they validate
- **Doc actions are conservative** — only included when an increment makes existing docs obsolete, or when `AGENT.md`/`CLAUDE.md` instructions need updating

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

### Filtering Out the Architecture

Don't turn an agreed component design into behavior-only wording:
```markdown
**Action**: Add support for a second provider and retry rejected files
```

Instead, preserve the essential ownership and contract while leaving internals for execution:
```markdown
**Technical Design Constraints**:
- Separate provider clients share one normalized contract
- The selection policy chooses the provider; the orchestrator owns retry behavior
```

### Tests as a Separate Step

Don't isolate tests into their own step:
```markdown
Step 4: Write tests
```

Instead, include them in the relevant increment:
```markdown
Step 2: User can filter list
**Actions**:
- Filter data based on search query
- Update UI to show filtered results
- Add unit tests for filter logic
- Add integration test for search interaction
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
2. **Inspect the codebase** - Identify the files, tests, docs, and patterns most relevant to the plan
3. **Write the opening context** - State the problem, goal, high-level approach, and scope in user-readable language
4. **Add Code Pointers** - List concrete files with a brief reason each
5. **Preserve technical design** - Extract settled boundaries, contracts, responsibility ownership, and invariants without expanding into implementation mechanics
6. **Identify functional increments** - What can user test at each step?
7. **Add diagrams when needed** - Visualize complex flows only
8. **Document decisions** - Capture important choices made
9. **Create checklist** - Summary for quick reference
10. **Run quality gate** - Ensure increments are testable and plan is executable
11. **Iterate with user** - Refine plan before implementation

## Example Plan

See [EXAMPLE.md](references/EXAMPLE.md) for a complete plan following this format.
