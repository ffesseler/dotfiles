---
name: eval-authoring
description: Guide the creation, modification, debugging, and stabilization of LLM or prompt evals. Use whenever a session requires adding or changing an eval, changing a prompt to satisfy an eval, investigating an eval failure, adjusting a grader or assertion, or validating that a prompt behavior is reliable—even when the user does not explicitly ask for this skill.
---

# Eval Authoring

Develop evals and prompts through small, evidence-driven iterations. Protect the behavior being requested without coupling an eval to unrelated output details or fitting the prompt to one reported example.

## Core principles

- Evaluate only the minimum criteria needed to demonstrate the target behavior. An eval must not fail because of a criterion unrelated to the behavior it owns.
- Keep evals as independent as possible so each failure has one interpretable meaning.
- Use an analogous case rather than reproducing the reported problem exactly. The case must exercise the same general behavior with different concrete details, reducing the risk of prompt overfitting.
- Add only the smallest prompt change that could produce the target behavior. Do not bundle speculative wording or multiple defensive changes.
- Treat prompt changes as hypotheses. Use eval results to identify which wording actually changes behavior.

## Workflow

### 1. Define the behavior

State the single observable behavior being introduced or changed. Identify:

- the eval that will own this behavior;
- the minimum pass criteria;
- details that must remain outside its verdict;
- an analogous test case that differs from the reported incident while exercising the same behavior.

If one eval would cover several separable behaviors, split it into independent evals.

### 2. Establish a failing eval first

Before changing the prompt:

1. Create or modify the eval so it demonstrates the target behavior.
2. Run it against the current prompt.
3. Confirm that it fails specifically because the target behavior is not achieved.

Do not change the prompt until this expected failure has been observed. If the eval already passes, report that it does not demonstrate the missing behavior and revise the case or pass criteria without making them artificially strict.

### 3. Change the correct prompt section

Read the surrounding prompt and identify the section that owns the behavior. Prefer a local rule in the semantically relevant section over a priority exception placed in a broad, general-purpose section.

If the behavior remains difficult to elicit and the next step would introduce a special priority rule, move or create prompt structure, or otherwise broaden the intervention, pause before editing. Explain what you are about to change, why the existing section is insufficient, and ask the user whether to continue.

Make one minimal prompt change at a time. Do not add several formulations “for safety.”

### 4. Test for reliability

After the first prompt change:

1. Run the target eval 3 times.
2. If all 3 pass, continue to the simplification check.
3. If the target behavior is still missing, make the smallest additional prompt change and run the eval once.
4. Repeat one minimal change followed by one run until the first success.
5. After the first success, run the eval 3 more times.

A success followed by failures is not stable success. Continue classifying the failures and iterating minimally.

### 5. Classify every failure

For every failed run, record exactly one primary category and the evidence for it:

1. **Target behavior not achieved** — the eval correctly exposes that the intended behavior is still missing. Continue with one minimal prompt change.
2. **Unrelated or pre-existing failure** — the run failed on behavior outside the requested change. Pause, report the issue, propose how to isolate or address it, and ask the user before continuing.
3. **Verification formulation problem** — the assertion, grader, rubric, fixture, or threshold is too strict, too lax, ambiguous, or otherwise does not measure the intended behavior. Pause, report the issue, propose the minimal eval correction, and ask the user before continuing.

Do not hide categories 2 or 3 by modifying the prompt.

Use this concise report:

```text
Failure category: <target behavior | unrelated/pre-existing | verification formulation>
Evidence: <what the run did and which criterion failed>
Next step: <minimal prompt change, or proposed eval/isolation correction>
```

### 6. Remove prompt wording that did not earn its place

When several prompt changes were made before obtaining one success followed by 3 successful runs, review the history. Determine whether only the last change caused the improvement or whether earlier changes are also necessary.

Remove one apparently ineffective prompt fragment at a time, then rerun the reliability sequence. Keep a fragment only when results provide evidence that it contributes to stable success. Do not leave accumulated wording merely because the final version passes.

## Completion criteria

Finish only when:

- the eval checks only the target behavior;
- the test case is analogous, not a copy of the reported incident;
- the original prompt was shown to fail for the expected reason;
- the final prompt passes the target eval 3 times consecutively;
- every observed failure was classified;
- prompt wording unsupported by the iteration history was removed or explicitly justified;
- unrelated failures or verification defects were reported and handled only with user approval.

Conclude with a compact summary of the behavior tested, the prompt change retained, run outcomes, failure classifications, and any residual uncertainty.
