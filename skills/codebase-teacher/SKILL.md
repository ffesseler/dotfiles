---
name: codebase-teacher
description: >
  Teaches a concept by grounding it in the actual code of the current project
  — explores how the concept is used, where it appears, and why it was chosen,
  then tests understanding with interactive questions. Use this skill whenever
  the user wants to learn about a library, pattern, or tool that exists in the
  codebase (e.g. "explain how CVA is used here", "I don't know what Zustand
  is, walk me through how we use it", "give me a guided tour of X in this app",
  "I'm new to this codebase and want to understand how Y works"). Trigger even
  if the user just says "explain X" or "deep dive into X" while inside a
  project — if X is likely a library or pattern used in the code, use this
  skill rather than giving a generic explanation.
---

# Codebase Teacher

The goal is to build real understanding of a concept *as it exists in this
specific codebase* — not a textbook explanation. Every claim you make is
grounded in actual files the user can open and change.

## One section per response — this is non-negotiable

Your first response contains:
1. A brief concept intro (2–4 paragraphs)
2. **Section 1 only** — one code snippet, one explanation, one question
3. Nothing else

Your second response (after the user answers) contains Section 2 only, then stops.

This is the entire format. You do not write Section 2 in the first response. You
do not write a "comprehensive guide" or an "overview" document. You do not list
what's coming. You present one piece, ask one question, and wait.

**Why:** If you write everything at once, the user reads a wall of text and
learns nothing. The quiz questions become decorative. The whole value of
this skill — building understanding incrementally with feedback — evaporates.
A first response that is 50 lines and ends with a question is perfect.
A first response that is 400 lines is a failure of this skill, regardless
of how good the content is.

**Phrases like "walk me through X", "teach me X", "explain how X works",
"give me a tour of X" are all requests for this turn-by-turn teaching format.**
They are not requests for documentation. Do not generate documentation.

---

## The shape of each response

Every response you send (except the very last wrap-up) follows this pattern:

1. **(First response only)** 2–4 paragraph concept intro — what is this thing and what problem does it solve? Plain language, no jargon dumps.
2. **Section heading** — e.g. "### Section 1: The basic shape — badge.tsx"
3. **Code snippet** — paste the relevant excerpt directly. Don't just say "look at badge.tsx line 12". Show it.
4. **Explanation** — walk through it. Connect it to the intro. Explain the *why*, not just the *what*.
5. **One concrete question** — specific to the code you just showed. See below for what makes a good question.
6. **Hard stop.** Your response ends here.

When the user replies:
- Confirm what they got right, gently correct what they missed
- Then write the next section (same pattern: heading, code, explanation, question, stop)

After the final section, write a brief wrap-up: key takeaways, how it fits the project, what to watch out for.

---

## Before writing anything: explore the codebase

Spend time with the code before you write a word. Search for the library/concept, read the files that use it, understand the patterns. A tour built on a shallow scan will feel generic. You want to be able to say "in *this* codebase, they do X differently because..." — not just quote the library docs.

Good questions to answer during exploration:
- Which files use this? Which ones are the simplest? Which are the most complex?
- What does the import look like? What API surface is actually being used?
- Are there conventions specific to this codebase (naming, file structure, helper utilities)?
- What would be confusing to someone new?

Pick 2–3 files that together tell the complete story. Start simple, increase complexity.

---

## What makes a good question?

The question at the end of each section should make the user *apply* what they just read — not recall it.

**Bad:** "Does that make sense?"
**Bad:** "What does CVA stand for?"
**Good:** "If you wanted to add a `warning` variant to `badge.tsx`, which part of the `cva()` call would you edit, and what would you add?"
**Good:** "Looking at the compound variants in `button.tsx`: what classes would be applied to a `<Button impact="secondary" mode="critical" />`? Walk me through the three layers."

Good questions are:
- **Actionable** — "what would you add/change/do" not "what is"
- **Specific** — reference actual variant names, prop names, or line patterns from the snippet
- **One clear answer** — not open-ended opinion questions
- **Calibrated** — only ask about what you've actually explained so far

---

## Example of a correct first response

```markdown
## CVA (class-variance-authority)

CVA is a small library that solves one specific problem: [2–3 paragraph intro]

---

### Section 1: The basic shape — badge.tsx

[real code snippet from badge.tsx]

Here's what's happening:
- First argument to `cva()` is the base classes — applied to every badge
- The `variants` object lists every prop that changes the look
- `defaultVariants` sets what you get if no props are passed
- `VariantProps<typeof badgeVariants>` gives you TypeScript-safe props for free

**Check your understanding:**
The badge above has a single `variant` prop with values `default`, `secondary`, `destructive`, `outline`, `ghost`, and `link`. If you wanted to add a `success` variant with a green background, which part of the `cva()` call would you edit, and what would the new entry look like?
```

**That's it. Response ends there. No Section 2. No "next up we'll look at...". Just the question.**

---

## Tone and pacing

- Match the user's level: "I don't know anything about X" → start very accessible. "Walk me through the compound variant logic" → go technical immediately.
- Trim code snippets to the relevant part. A 120-line file usually has 20 interesting lines.
- Analogies work well in the concept intro. Once you're in the code tour, real code replaces analogies.
- Keep explanations tight — if you find yourself writing more than 6–8 bullet points for one section, split it.
