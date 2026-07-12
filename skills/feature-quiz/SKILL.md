---
name: feature-quiz
description: >
  Quiz the user on a feature recently introduced in the codebase, by analyzing
  a range of git commits and asking progressively deeper questions to help
  them build or refresh their mental model. Use this skill whenever the user
  wants to be quizzed, tested, or "drilled" on a feature, branch, PR, or
  commit range — phrases like "/feature-quiz", "quiz me on commits A..B",
  "quiz me on this branch", "help me memorize what this PR does", "test my
  understanding of the last few commits", or "I want to internalize what was
  just shipped". Especially relevant when the user mentions that the code was
  AI-generated or that they don't remember it well. Default activation form
  is `/feature-quiz <start>..<end>` but trigger on natural-language variants
  too. Do NOT use this skill for plain code explanations or walkthroughs
  without quizzing — for that, use codebase-teacher or expert-teacher.
---

# Feature Quiz

The goal is to help the developer **build a durable mental model** of a feature
they may not have written by hand (often AI-generated code), by quizzing them
on it. Reading code passively is forgettable; being asked questions and having
to answer forces retrieval, which is what actually creates memory.

This skill is **interactive and turn-by-turn**. You ask one question, wait for
the answer, react to it, then ask the next. You do not produce a study guide,
a summary, or a list of "things to know". The whole point is the back-and-forth.

---

## Inputs

The user provides a commit range. Common forms:

- `/feature-quiz abc123..def456`
- `/feature-quiz abc123 def456`
- "quiz me on the last 5 commits" → use `HEAD~5..HEAD`
- "quiz me on this branch" → use `<merge-base with main/develop>..HEAD`
- "quiz me on PR #123" → fetch the PR's commit range via `gh`

If the range is ambiguous, ask once and proceed. Don't over-clarify.

---

## Phase 1: Analyze the feature (silent prep)

Before asking any questions, gather context. The user does not see this work in
detail — just a brief summary at the end.

Run, in parallel where possible:

1. `git log --oneline <range>` — commit messages, in order
2. `git log <range>` — full commit messages with bodies
3. `git diff <range> --stat` — files touched + size of changes
4. `git diff <range>` — the actual code changes

For files with substantial changes, also `Read` the surrounding code in the
final state so you understand context that the diff alone doesn't show
(imports, sibling files, callers). Don't read everything — be selective; focus
on files central to the feature.

**Build a mental map of the feature:**

- What problem does this feature solve? (from commit messages)
- What are the major *parts* of the implementation? Think in layers or
  responsibilities — e.g. "data model + migration", "service/business logic",
  "API/server action surface", "UI", "tests", "background jobs". Adapt the
  taxonomy to what's actually in the diff.
- **Data flow**: Map the end-to-end path data takes — from trigger (user action,
  cron, event) through each layer (route → service → repository → DB → back) to
  its final resting place or side effect. This is almost always worth a question.
- **Design decisions**: Note places where a non-obvious choice was made. Why a
  Postgres function instead of application-level SQL? Why a LATERAL join instead
  of a subquery? Why write to two tables instead of one? Why push logic into SQL
  instead of the service? These "why X instead of Y" moments are high-value.
- **Technical patterns**: Identify any non-trivial SQL (window functions, LATERAL
  joins, CTEs, aggregates), algorithms, or data structures. These are concrete
  and testable.
- What are the other non-obvious bits? (a weird abstraction, a workaround, a
  security/permission check, a perf trick) — these make good deeper questions.

You are now the examiner. You know the answers. The user is being tested.

---

## Phase 2: Open the session

Send a short opening message:

1. One or two sentences naming the feature and what it does (so the user knows
   you understood the range correctly — and can correct you if not).
2. A list of the **major parts** you've identified (3–6 bullets), so the user
   can see the scope of the quiz. This also primes their memory.
3. Tell them you'll ask ~6–8 questions, starting broad and going deeper, and
   that they should answer in their own words — guessing is fine, partial is
   fine, "I don't know" is fine.
4. Ask **the first question** — and stop.

That's the whole opening message. Do not pre-write any later questions.

---

## Phase 3: The quiz loop

You ask one question. The user answers. You respond. You ask the next question.
Repeat.

### Question 1 — broad, high-level

Always start with something like: *"In your own words, what does this feature
do and why was it added?"* or *"Walk me through what happens, end-to-end, when
[user-facing trigger] occurs."*

This sets the frame and tells you how much they already know — which guides
the depth and direction of subsequent questions.

### Questions 2–7 — drill into specific parts

After the high-level question, each subsequent question targets **one specific
part** of the implementation. Pick parts based on:

- **Coverage**: by the end of the quiz, the user should have been asked about
  every major part you identified in Phase 1. Don't dwell on one layer.
- **Weak spots**: if the user's answer revealed a misconception or a gap, the
  next question should probe nearby — but not interrogate the same point
  three times in a row. One follow-up to clarify, then move on.
- **Non-obvious bits**: lean toward the parts of the implementation that
  someone reading it for the first time would *miss* or *get wrong*. Trivial
  questions ("what does this function return") are wasted turns.

**Priority question types** — aim to cover all of these across the quiz:

1. **Data flow**: Ask the user to trace how data moves end-to-end through the
   feature. This is almost always worth a dedicated question. *"Walk me through
   what happens, step by step, from [trigger] to [outcome]."* or *"Where does
   [piece of data] come from, and how does it reach [its destination]?"*

2. **Design decisions**: Ask why a specific technical choice was made over the
   obvious alternative. Good fodder: why a Postgres function vs. app-level SQL,
   why a particular join strategy, why push logic into SQL vs. a service, why
   write to two tables, why a specific data structure. *"Why was [X] done as
   [approach] instead of [simpler alternative]?"*

3. **Technical patterns**: If the diff contains non-trivial SQL (LATERAL joins,
   window functions, CTEs, aggregates) or complex algorithms, ask about the
   mechanism — not "what is a LATERAL join" in the abstract, but "what does the
   LATERAL join do here, and what would break if you replaced it with a
   subquery?" Paste a short excerpt (≤10 lines) when useful.

4. **Edge cases and behavior**: *"What happens when [input is null / no data /
   concurrent write]?"* or *"What would break if we removed [this check]?"*

**Keep refactoring questions to at most one or two.** Refactoring (moving code,
renaming, extracting services) is real work but rarely needs memorizing. One
question on *why* a significant refactor was done is fine; don't spend turns on
*what* moved where unless the destination is architecturally meaningful.

Vary the question shape:

- *"Trace the path of [data] from [entry] to [exit]."*
- *"Why was [specific choice] made instead of [obvious alternative]?"*
- *"What does [this SQL pattern] do here, and why not [simpler approach]?"*
- *"What table/file/function holds X, and why there?"*
- *"If [edge case] happens, what does the system do?"*
- *"What would break if we removed [this line/check/call]?"*

Keep each question **short** — one sentence, occasionally two. Do not paste
large code blocks into questions; if pointing at code is necessary, paste a
small excerpt (≤10 lines) and ask about it.

### Final question — synthesis

The last question should pull threads together. Examples: *"If you had to
review this PR cold, what's the part you'd push back on?"* or *"What's the
weakest assumption this feature relies on?"*

This forces the user to think about the feature as a whole rather than as
isolated pieces — which is what cements the mental model.

---

## How to react to each answer

After the user answers, before asking the next question:

1. **Acknowledge what they got right** — specifically, not just "good".
2. **Correct what they missed or got wrong** — show the actual code or commit
   that proves it. Be concrete. A correction without evidence is forgettable.
3. **Add one piece of context** they probably didn't know — a related decision,
   an edge case, a "this is also how X works because of this".
4. Then ask the next question.

Keep this reaction tight. ~3–8 lines is right. The user is here to be quizzed,
not lectured. If you find yourself writing a paragraph, you're explaining when
you should be asking.

If the user says "I don't know" — don't punish, just give the answer briefly
and move on. Skip the correction step. The next question still advances.

---

## Phase 4: Wrap up

After ~6–8 questions, close the session with:

- A 3–5 bullet **recap** of the feature's mental model — the things they should
  remember a week from now. Phrase these as *facts about the feature*, not
  *things you asked them*.
- One sentence on the parts the user seemed shakiest on, with file paths so
  they can revisit.

Then stop. No "let me know if you want another round" filler.

---

## Things to avoid

- **Don't dump the whole feature analysis up front.** The user should learn the
  feature *through the questions*, not before them. If you summarize everything
  in the opening, the quiz is decorative.
- **Don't ask trivia.** "What's the name of the function?" is useless. Ask
  about behavior, decisions, edge cases, data flow.
- **Don't ask multi-part questions.** "What does X do, and why, and what
  happens if Y?" — pick one. Multi-part questions get partial answers and
  muddy the next turn.
- **Don't grade harshly.** This is a memory-building tool, not an exam. The
  user is doing the right thing by engaging at all.
- **Don't keep going past ~8 questions** unless the user explicitly asks for
  more. Diminishing returns hit fast and the recap is more valuable than a
  ninth question.

---

## Example opening (for shape reference, not content)

> I've looked at commits `abc123..def456` — this introduces **video analytics
> per restaurant account**, replacing the old per-video stats route with an
> account-level summary.
>
> The major parts:
> - New TypeORM repository for video analytics (`src/backend/repositories/...`)
> - Service-layer authorization moved out of the route
> - Stats route now delegates access checks to the service
> - Account-level aggregation query + new DTO
> - Frontend summary card on the account dashboard
>
> I'll ask ~7 questions, starting broad and getting more specific. Answer in
> your own words — guessing is fine.
>
> **Q1.** In your own words, what does this feature change about how a
> restaurant owner sees their video performance, and why was the old
> per-video route insufficient?
