# Step Review Prompt Template

Run after a step's commits are done. Fill the placeholders, generate the diff section,
write everything to a temp file, then run:

```bash
git log --oneline {{START_SHA}}..{{END_SHA}} > /tmp/step-commits.txt
git diff --stat {{START_SHA}}..{{END_SHA}} > /tmp/step-diffstat.txt
git diff {{START_SHA}}..{{END_SHA}} > /tmp/step-diff.txt
# assemble prompt file, then:
"{{FEATURE_PIPELINE_SKILL_DIR}}/scripts/fresh-review" {{ENGINE}} /tmp/step-review-prompt.md plans/reviews/{{PLAN_SLUG}}-step-{{NN}}-review-{{TIMESTAMP}}.md
```

If the full diff exceeds ~3000 lines, include only `git log --oneline` + `--stat` and
instruct the reviewer to read changed files / run git itself (codex, pi and opencode can;
gemini and claude run read-only and need the diff inline).

---

## Template

```
You are a senior engineer reviewing the implementation of ONE step of a plan, with
FRESH EYES. You did not write the plan or the code.

Repository root: {{REPO_ROOT}}
Plan file: {{PLAN_PATH}}
Step under review: Step {{STEP_NUMBER}} — {{STEP_TITLE}}
Detailed step plan (if present): {{DETAILED_PLAN_PATH}}
Commit range: {{START_SHA}}..{{END_SHA}}

Read the plan file (at minimum the context section and Step {{STEP_NUMBER}}), then
review the commits below. You may read any file in the repository for context, but DO
NOT modify anything.

Evaluate:

1. PLAN CONFORMANCE — Does the implementation do what Step {{STEP_NUMBER}} says? List
   any scope added, dropped, or silently changed vs the plan.
2. DRIFT — Decisions taken during implementation that contradict the plan's context,
   earlier steps' established contracts, or constraints stated elsewhere in the plan.
3. CORRECTNESS — Bugs, broken edge cases, missing error handling in the changed code.
4. CONSISTENCY — Violations of the repository's own conventions visible in surrounding
   code (layering, naming, logging, types).
5. TEST COVERAGE — Does the step meet the plan's validation requirements?
6. SUBSTEP/COMMIT BOUNDARIES — If the detailed step plan contains numbered substeps,
   does the commit range contain one focused commit per planned substep? Flag batched
   commits, commits that mix substeps, or substeps with no corresponding commit.

Commits in range:
{{COMMITS_ONELINE}}

Diffstat:
{{DIFFSTAT}}

Full diff:
{{DIFF}}

Output format (strict):

## Verdict
One short paragraph: does this step faithfully implement the plan?

## Findings
A numbered list. For each finding:
- **[N] <short title>** — severity: `blocking` | `major` | `minor`
  - What: the issue, with file:line or commit evidence.
  - Why it matters.
  - Concrete case: a specific scenario showing the issue biting (input, flow, or data
    from this repository).
  - Fix options: the viable fixes labeled (a), (b)..., each with a one-line trade-off
    (single option allowed when only one makes sense). End with
    `Preferred: <letter> — <one line why>`.

Only report real issues. No praise sections, no generic advice.
```
