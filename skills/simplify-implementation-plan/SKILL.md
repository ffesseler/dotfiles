---
name: simplify-implementation-plan
description: Simplify a detailed implementation plan produced by plan-executor or feature-pipeline before implementation begins. Use whenever the user asks for a simplification pass, a simpler implementation, removal of unnecessary complexity, YAGNI review, or scope reduction after detailed planning. Review the whole detailed plan by default or only the explicitly named substep, while preserving required behavior and validation gates.
---

# Simplify Implementation Plan

Simplify a detailed plan before code is written, without weakening its requested behavior or constraints.

## Run the pass

1. Identify and read the detailed plan produced by `plan-executor` or `feature-pipeline` (e.g. `plans/step-NN-detailed-plan.md`). Ask for it only when it cannot be recovered from the request or conversation.
2. Review the whole plan by default. If the user names a substep, read only its necessary context and revise only that substep; report consequences elsewhere without expanding scope.
3. Preserve the objective, observable result, explicit decisions, public contracts, security and operational constraints, behavioral tests, and cohesion and validation gates.
4. Inspect code only when needed to verify a consumer, constraint, or existing pattern.
5. Use the categories below to find evidence-backed changes. Explain what to remove, replace, or defer and any relevant trade-off.
6. Rewrite the selected scope with its structure and validation intact. If invoked interactively or under substep/step autonomy, ask the user to approve it; under full autonomy in automated pipelines, save the simplified plan and proceed without interactive approval. Do not implement code during this pass.

Do not manufacture changes. A plan is not simpler when it hides work, moves complexity elsewhere, or removes evidence that the result works. Add a concept only when it has a current consumer, distinct responsibility, or invariant to protect. Leave an already-simple plan unchanged.

## Simplification categories

### 1. Remove speculative generality — YAGNI

Remove machinery that does not serve the requested increment.

| Item | Apply when | Example |
|---|---|---|
| Unrequested behavior | A planned capability has no approved use case in the increment. | Keep requested previous/next buttons but omit unrequested keyboard shortcuts. |
| Single-use abstraction | An interface, factory, strategy, hierarchy, or registry has one implementation and no identified second use. | Use a local retry helper instead of a retry factory and specialized class for one caller. |
| Configuration without choice | A field or option has only one valid value under the supported behavior. | Omit `analyzerVersion` when analyzer versions do not coexist or require separate cache identities. |
| Premature extension point | A hook, plugin mechanism, or generic parameter exists only for hypothetical future expansion. | Call the sole document analyzer directly instead of adding an analyzer registry. |
| Disproportionate coverage | Planned cases, types, or machinery cost more than their identified user value. | Support `supply_document` instead of adding a taxonomy and routing for unrequested document types. |

Keep an element when it supports an explicit requirement, known consumer, external contract, security or data-integrity boundary, supported deployment mode, or observed failure requiring recovery.

### 2. Simplify the data model

Keep one canonical representation and model only what consumers need.

| Item | Apply when | Example |
|---|---|---|
| Single source of truth | Existing data can directly carry the required information. | Add `relevantToRequest` to extracted elements instead of creating a parallel `quoteFacts` collection. |
| Consumer-sized contract | Consumers use less information than the planned structure exposes. | Use a relevance boolean instead of a business taxonomy when consumers only filter elements. |
| Derived value | A value can be computed simply from canonical data. | Compute `hasRelevantItems` with `items.some(...)` instead of storing and synchronizing it. |
| Canonical vocabulary | An existing domain type or value already owns the concept. | Reuse `technical_drawing` instead of introducing the synonym `construction_plan`. |
| Proportional persistence | Stored data has no future read, audit, or recovery use, or duplicates a larger canonical value. | Keep one source payload and derive its views instead of persisting the raw value and redundant projections. |

Keep a separate model when it represents a distinct domain concept, protects an external boundary, or has an independent lifecycle.

### 3. Centralize responsibilities

Give shared behavior one owner at the nearest common boundary.

| Item | Apply when | Example |
|---|---|---|
| Transverse mechanism | Several consumers repeat the same non-domain behavior. | Capture Langfuse generations in `MastraAssistantTextGenerator` instead of every business generator. |
| Common behavior path | Two workflows perform the same operation under the same rules. | Reuse one document analyzer for quote and supplier-import flows instead of maintaining equivalent extraction paths. |
| Owning boundary | Intermediate layers handle a decision owned by a boundary with fuller context. | Log a failure once where its handling is decided instead of logging and rethrowing it at every layer. |

Keep separate owners when behaviors only look similar but have different invariants, lifecycles, or failure policies. Do not create a catch-all service in the name of centralization.

### 4. Remove technical plumbing

Keep data and control flow direct when intermediate machinery adds no semantics.

| Item | Apply when | Example |
|---|---|---|
| Internal encoding and parsing | Structured data is serialized only for another internal component to parse it. | Pass the original selection structure instead of textual references decoded by `parseQuoteFactSelection`. |
| Behaviorless wrapper | A class or object adds no invariant, adaptation, or behavior. | Return `AnalysisResult` instead of wrapping it as `{ result }` in `ProcessedAnalysisResult`. |
| Mechanical delegation | A mapper, service, or helper only copies fields or forwards an invocation. | Pass an already validated DTO to the service instead of mapping every field identically. |
| State for a single flow | Specialized errors or coordination objects express a flow that local state can represent clearly. | Keep `lastAnalysis` in a retry helper instead of adding a repair error and dedicated repair types. |
| Indirect data flow | Intermediaries only transport or convert data without making a decision. | Pass a typed selection to its consumer instead of routing it through a context that encodes and reparses it. |

Keep a layer when it protects a boundary, validates a contract, translates distinct models, or owns a reused policy.

### 5. Simplify operations

Match migration and compatibility machinery to the deployment modes that are actually supported.

| Item | Apply when | Example |
|---|---|---|
| Real deployment strategy | Old and new application versions do not need to coexist. | Use one canonical migration instead of a multi-phase transition for an undeployed feature. |
| Bounded compatibility | A controlled migration has removed the need for historical reads and dual writes. | Write only `technical_drawing` after migration instead of continuing to support `construction_plan`. |
| Explicit one-time operation | An operation should run once rather than remain in the application lifecycle. | Run a migration through a controlled command instead of application startup or watch-mode restarts. |

Keep progressive rollout when versions genuinely coexist, rollback is required, or data volume makes a one-shot migration unsafe.

### 6. Simplify tests and presentation

Keep validation and user-facing output proportional to their value.

| Item | Apply when | Example |
|---|---|---|
| High-value cases | Marginal combinations cost more to maintain than the risk they detect. | Test the nominal flow, a frequent incomplete document, and a critical contradiction instead of many rare ambiguity combinations. |
| Minimal fixture | Test data contains context unrelated to the behavior under evaluation. | Use a quote with one service to evaluate scaffolding addition instead of a complete roofing quote. |
| Validation owner | Several layers test a decision owned by one component. | Check a compliance rule during generation when scoping is not responsible for guaranteeing it. |
| Minimal user projection | Presentation exposes more structure than users need for the action. | Show a photo icon in the Messages column instead of adding a dedicated Photos column. |
| Presentation-only reduction | The display needs less information but the source remains useful internally. | Show visible-work labels without reducing the underlying structured photo analysis. |

Keep rare cases that protect against data loss, incorrect amounts, security failures, or unrecoverable states. Before removing a complex test, verify that its behavior is covered at the owning boundary.

## Response

Concisely state the reviewed scope and preserved contract, then show only justified simplifications, trade-offs, the revised scope, and retained validation. Under interactive or substep/step autonomy, end with: `Does this simplified plan look good, or would you like adjustments?` Under full autonomy, state the applied simplifications and proceed directly without user validation.
