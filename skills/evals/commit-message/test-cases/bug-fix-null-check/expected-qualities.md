# Expected Qualities for Commit Message

This document defines the criteria that should be met by a well-written commit message for this test case. It's not a golden example, but a rubric for evaluation.

## Structural Requirements

- [ ] Subject line ≤ 50 characters
- [ ] Subject line has no ending period
- [ ] Blank line separates subject from body
- [ ] Body lines wrapped at 72 characters
- [ ] Subject line is descriptive and distinguishable

## Content Requirements - Clarity

- [ ] Subject mentions the fix context (e.g., "refund", "null check", "deleted payment method")
- [ ] Body explains the before state: code assumed payment method always exists
- [ ] Body explains the after state: now checks for null and uses cached data
- [ ] Message is self-contained (understandable without external resources)

## Content Requirements - Completeness

- [ ] Explains WHY the bug happened (deleted payment methods)
- [ ] Explains WHY this solution was chosen (cached data available, user freedom)
- [ ] Mentions the user impact (crashes during refunds)
- [ ] Includes rationale for the approach (refunds must complete successfully)

## Content Requirements - Detail Balance

- [ ] Appropriate detail level for a straightforward bug fix (2-4 sentences or 1-2 short paragraphs)
- [ ] Does NOT include unnecessary "Test Plan:" section (this is routine testing)
- [ ] Does NOT include verbose "Changes:" list that mirrors the diff
- [ ] Focuses on non-obvious context and rationale
- [ ] Avoids over-explaining what's visible in the diff

## Scoring Guidelines

Based on SKILL.md principles:

**Structure (0-2 points)**: Character limits, formatting, line wrapping
**Clarity (0-3 points)**: Pyramid structure, before/after states, self-containment
**Completeness (0-3 points)**: Why over what, rationale, user impact
**Detail Balance (0-2 points)**: Appropriate for complexity, no over-documentation

**Total: 10 points** (threshold ≥ 7 for pass)

## What Good Looks Like (Not Prescriptive)

A good commit message for this change would:
- Lead with the fix and impact (pyramid structure)
- Explain the root cause briefly (deleted payment methods)
- Describe the solution approach (null check + cached data)
- Justify why this matters (refunds must complete)
- Stay concise (this is a clear-cut bug fix, not a complex architectural change)

## What to Avoid

- Generic subject: "Fix bug" or "Update refund handler"
- Over-documentation: Multi-paragraph explanation with "Changes:" list
- Under-documentation: Just "Add null check" without explaining why
- Redundancy: Restating what's obvious from the diff
