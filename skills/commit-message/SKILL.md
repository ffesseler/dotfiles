---
name: commit-message
description: Guide for writing clear, informative commit messages. Use when (1) creating git commits, (2) user asks about commit message writing, (3) reviewing or improving existing commit messages, (4) user wants guidance on commit message structure or content. Supports optional --format=conventional parameter for Conventional Commits (default is canonical format). Helps write messages that serve multiple audiences (users, reviewers, future developers) and remain valuable years later.
---

# Commit Message Writing Guide

This skill provides comprehensive guidance for writing high-quality commit messages based on two canonical sources: Simon Tatham's blog post on commit messages and the OpenStack GitCommitMessages wiki.

## ⚠️ CRITICAL: This Skill Only PROPOSES Commit Messages

**NEVER create commits yourself.** This skill's ONLY purpose is to:

1. ✅ Analyze git changes and conversation context
2. ✅ Draft a well-structured commit message
3. ✅ Copy the message to clipboard for user to use
4. ❌ NEVER run `git commit` commands
5. ❌ NEVER actually create commits

**Your role:** Propose the commit message, explain your reasoning, copy it to clipboard, then let the USER decide when and how to commit.

## Usage

**Basic invocation:**
```
/commit-message
```

**With Conventional Commits format:**
```
/commit-message --format=conventional
```

By default, this skill follows the canonical commit message structure from Simon Tatham and OpenStack guidelines. Use `--format=conventional` only if your project requires Conventional Commits format.

## Quick Reference

**Subject Line (First Line)**
- 50 characters maximum
- Make each commit distinguishable
- Include ticket IDs if applicable
- For default (non-conventional) format, do not use prefixes

**Body**
- Blank line after subject
- 72-character line wrap
- Lead with most important information (pyramid structure)
- Explain the "why" not just the "how"
- Use high-level, plain language before technical details
- Plain text compatible (minimal Markdown)

**One Logical Change Per Commit**
- Split whitespace changes from functional changes
- Separate refactoring from new features
- Each commit should be independently reviewable

## Core Principles

### Multiple Audiences

Commit messages serve different readers:
- **Project users** - Deciding whether to update
- **Bug investigators** - Using git bisect to trace behavior changes
- **Code reviewers** - Evaluating patches
- **Other developers** - Understanding project evolution
- **Your future self** - Remembering your reasoning

### Primary Value

Communicate information that readers cannot easily extract from the code itself. Focus on context, rationale, and implications rather than restating what the diff already shows.

**Balance detail with signal-to-noise ratio:** Include enough context to understand the change years later, but avoid redundant explanations of obvious changes. Ask: "What would I need to know if investigating this commit in 2 years?"

### Self-Containment

Messages must be understandable years later without access to bug trackers, email threads, or external documentation. Include enough detail for independent review.

## Structure Guidelines

### Subject Line Format

Maximum 50 characters. Make each commit distinguishable from others.

**Patterns:**
```
Fix crash when user profile is incomplete (#44142)
Switch CPU info lookup to config APIs
Extract user authentication logic to separate module
```

**Include:**
- Ticket/issue IDs in parentheses
- Clear high-level problem/solution wording

**Avoid:**
- Generic descriptions: "Bug fix", "Updates", "Changes"
- Reusing ticket titles verbatim without context
- Prefixes in default format (for example: `auth:`, `NFC:`)
- Ending period

### Body Structure

1. **Blank line** after subject line (required)
2. **Lead paragraph** - Most important information first
3. **Details** - Explanation, rationale, side effects
4. **Optional sections** - Test Plan, references, metadata
5. **Wrap at 72 characters** for plain text compatibility

### Pyramid Structure

Put the most important information at the top. Let readers stop when they've found what they need.

**Good:**
```
Implement client-side validation for profile forms to prevent
incomplete submissions. Before this change, users could save profiles
with missing required fields, causing API errors.

New validation checks:
- Email format verification
- Required field presence
- Character limits on text fields
```

**Bad:**
```
After extensive analysis of user feedback and consultation with the
product team about improving data quality across the application,
we decided to implement validation. The validation implementation
includes several checks for profile forms...
[Forces all readers to process background before understanding the change]
```

## Essential Content Checklist

Include these elements **when they add value beyond what's visible in the diff**. Not every commit needs all sections—use judgment based on change complexity:

### 1. Intended Behavior Change

What's different from a user's perspective? Even for refactoring, state "No user-visible changes" explicitly.

### 2. Rationale

Why was this change made? What problem does it solve?

### 3. Side Effects

Any unintended consequences? Justify why they're acceptable.

**Example:**
```
Side effect: Form submission is now slower by ~50ms due to
validation overhead, but this is acceptable for better data quality.
```

### 4. The Interesting Part

In large patches, guide readers to changes that actually affect behavior versus boilerplate.

### 5. Patch Structure

For complex changes, explain the organization. Clarify any reindentation, file movements, or counterintuitive ordering.

### 6. Omissions and Exceptions

Why weren't certain instances modified? Why not use an apparently easier approach?

### 7. External References

Bug tracker IDs, CVE numbers, related commit hashes, standards citations.

## Writing Style

### Explicit State Changes

Use clear language to distinguish between old and new code states.

**Good:**
```
Before this change, the code assumed payment_method_id always had
a corresponding record. Now, we check for null before accessing
payment method properties.
```

**Avoid:**
```
The code assumes payment_method_id has a corresponding record.
[Ambiguous - is this describing old or new behavior?]
```

### Explain Why, Not Just How

The diff shows what changed. The message should explain why.

**Good:**
```
Extract authentication logic to dedicated auth service. This prepares
for upcoming OAuth integration in ticket #9012.
```

**Avoid:**
```
Move authentication code from controllers to auth service.
[Restates what the diff shows without explaining rationale]
```

### Use High-Level Problem/Solution Language

Write for broad understanding first, then add implementation details
only when they are necessary.

**Prefer:**
- Plain language that a non-expert teammate can follow
- Clear framing of the user/business problem and the chosen solution
- Minimal jargon, acronyms, and internal code names

**Avoid:**
- Overly technical internals in the opening explanation
- Dense implementation details without stating the actual problem
- Messages that require deep codebase knowledge to understand

**Good:**
```
Prevent failed checkouts when payment sessions expire

Some users were dropped back to cart with no explanation when their
payment session timed out. We now detect expired sessions earlier and
show a clear retry path so checkout can continue safely.
```

**Too technical:**
```
Handle null PSP token in checkout orchestrator

Add guard in PaymentSessionService.resolveToken() to short-circuit
when provider payload omits psp_token and propagate RecoverableError.
```

### State the Original Problem

Make it clear what issue prompted the change.

**Good:**
```
Addresses crash when processing refunds for deleted payment methods.
The code assumed payment_method_id always had a corresponding record,
but deleted methods caused null references.
```

## Common Anti-Patterns

### Generic Descriptions
❌ "Bug fix"
❌ "Updates"
❌ "Changes to auth system"
✅ "Fix null pointer exception in payment refund flow (#5678)"

### Mixing Unrelated Changes
❌ Combining whitespace cleanup with functional changes
❌ Multiple unrelated features in one commit
✅ Split into separate commits for independent review

### Assuming External Access
❌ "Fixes the bug discussed in yesterday's standup"
❌ "See ticket #1234 for details"
✅ Include enough detail to understand without bug tracker access

### Lengthy Preamble
❌ Starting with extensive background before describing the change
✅ Lead with the change, then provide context

### Over-Documentation
❌ Explaining obvious changes visible in the diff
❌ Including routine testing details ("tested it works")
❌ Lengthy "Changes:" lists that mirror the diff
✅ Focus on non-obvious rationale and context

## Balancing Detail: When to Be Concise vs Detailed

### Be Concise When:

**Straightforward bug fixes:**
```
Prevent refund crashes when payment method data is missing

The code assumed payment_method_id was never null, causing crashes
when processing refunds for deleted payment methods. Now we check
for null and use cached payment data.
```

**Simple refactoring:**
```
Extract user validation to separate function

Reduces code duplication across auth and profile controllers.
No behavioral changes.
```

**Obvious improvements:**
```
Speed up login for users with large account tables

Login queries were doing full table scans. Added index reduces
query time from 200ms to 5ms.
```

### Be Detailed When:

**Complex architectural changes:**
```
Migrate session storage from memory to Redis

Switch from in-memory sessions to Redis-backed storage to support
horizontal scaling. Before this change, user sessions were lost
when deploying new instances or during instance failures.

Changes:
- Add Redis connection pool with retry logic
- Implement session serialization/deserialization
- Add session TTL configuration
- Migrate existing sessions on first request

Trade-offs:
- Adds Redis dependency (acceptable for scalability needs)
- Slightly slower session access (~5ms overhead)
- Sessions survive deployments and instance failures

Test Plan: Load tested with 10k concurrent users, verified session
persistence across deployments, tested Redis failover scenarios.
```

**Non-obvious solutions:**
```
Use temporary git branches for alert worktrees (#1234)

Create temporary branches (alert-temp-{timestamp}) instead of using
'main' directly for worktrees. The main repo directory is itself a
worktree for 'main', causing "fatal: 'main' is already checked out"
errors.

Alternative approaches considered:
- Cloning the repo: Too slow for frequent alerts (~30s per clone)
- Using git worktree add --detach: Breaks branch-based cleanup logic
- Reusing single worktree: Creates race conditions with concurrent alerts

Temporary branches are cleaned up after processing completes.
```

**Security or data integrity issues:**
```
Sanitize user input in comment rendering (CVE-2024-1234)

Escape HTML in user comments before rendering to prevent XSS attacks.
Before this change, users could inject <script> tags in comments.

Using DOMPurify for sanitization instead of manual regex escaping
because it handles edge cases (e.g., event handlers, data: URLs,
encoded characters).

SecurityImpact
Test Plan: Verified against XSS test suite, manual testing with
OWASP attack vectors
```

### Rule of Thumb:

- **Simple changes** (< 20 lines, single concept): 2-4 sentence body
- **Medium changes** (20-100 lines, clear purpose): 1-2 paragraph body
- **Complex changes** (> 100 lines, multiple concepts): Full structured explanation

Ask: "What questions would a reviewer have that aren't answered by reading the diff?"

### Reusing Ticket Titles
❌ Using ticket title verbatim without specificity
✅ Add context to make the commit distinguishable

## Optional Metadata Tags

Add at the end of commit message when applicable:

**Bug References:**
- `Closes-Bug: #NNNNN` - Fully resolves bug
- `Partial-Bug: #NNNNN` - Partial fix requiring additional work
- `Related-Bug: #NNNNN` - Related but doesn't resolve

**Impact Indicators:**
- `DocImpact` - Documentation changes needed
- `APIImpact` - Public HTTP API modifications
- `SecurityImpact` - Security-related changes
- `UpgradeImpact` - Upgrade implications

**Authorship:**
- Do not include co-author mentions in commit messages
- Avoid `Co-Authored-By:` lines

**Testing:**
- `Test Plan:` - Document **non-obvious** or **critical** manual testing performed
  - Include when testing was complex, had specific edge cases, or required special setup
  - Omit for routine changes where "ran the tests" is sufficient
  - Skip if automated tests cover the change adequately

## Example Templates

### Feature Addition

```
Add user profile validation (#1234)

Implement client-side validation for profile forms to prevent
incomplete submissions. Before this change, users could save profiles
with missing required fields, causing API errors.

New validation checks:
- Email format verification
- Required field presence
- Character limits on text fields

Side effect: Form submission is now slower by ~50ms due to
validation overhead, but this is acceptable for better data quality.

Test Plan: Manual testing of all profile forms with valid/invalid data
```

### Bug Fix

```
Fix null pointer exception in payment flow (CVE-2024-1234)

Addresses crash when processing refunds for deleted payment methods.
The code assumed payment_method_id always had a corresponding record,
but deleted methods caused null references.

Solution: Check for null before accessing payment method properties
and gracefully handle missing records by using cached data.

SecurityImpact: Prevents denial-of-service via malicious refund requests
Closes-Bug: #5678
```

### Refactoring (No Functional Change)

```
Simplify auth code to make future changes safer

Move authentication code from controllers to dedicated auth service.
This prepares for upcoming OAuth integration in ticket #9012.

No user-visible changes. All existing authentication flows work
identically.

Test Plan: Ran full test suite, manual login/logout verification
```

### Performance Optimization

```
Optimize database queries for user dashboard (#3456)

Reduce dashboard load time from 2.3s to 0.4s by adding indexes
and eliminating N+1 queries. Before this change, the dashboard
made separate queries for each user's recent activity.

Changes:
- Add indexing for frequent dashboard lookups
- Load related activity data in fewer queries
- Cache frequently accessed user preferences

Side effect: Database migration adds 50MB to index size, but
the performance improvement justifies this trade-off.

Test Plan: Load tested with 1000 concurrent users, verified
query performance in production staging
```

### Documentation Update

```
Update API authentication examples

Replace outdated OAuth1 examples with OAuth2 flow. The OAuth1
examples no longer work since we deprecated that authentication
method in v2.0 (commit abc123).

Updated:
- All curl examples now use Bearer tokens
- Added error handling examples
- Included token refresh workflow

DocImpact
Related-Bug: #7890
```

## Workflow for Creating Commit Messages

**🚫 CRITICAL RULE: NEVER RUN `git commit` COMMANDS**

This skill's workflow is:
1. **Analyze** changes and context
2. **Propose** a commit message
3. **Copy** to clipboard
4. **STOP** - Let the user commit

**Important:** When helping users write commit messages interactively, analyze BOTH the git changes AND the conversation history. The chat context often contains valuable rationale, design decisions, and explanations that should be captured in the commit message.

**After generating a commit message proposal, ALWAYS:**
1. Present the proposed message to the user
2. Explain your reasoning
3. Copy it to the clipboard using one of these commands:
   - macOS: `pbcopy`
   - Linux: `xclip -selection clipboard` or `xsel --clipboard --input`
   - Windows: `clip`
4. **Tell the user** they can now run `git commit` themselves

Example workflow:
```bash
# After crafting the commit message, copy it to clipboard
echo "Your commit message here" | pbcopy
```

**What you MUST do:**
- ✅ Show the proposed commit message
- ✅ Copy it to clipboard
- ✅ Tell user they can now commit with: `git commit -m "$(pbpaste)"`

**What you MUST NEVER do:**
- ❌ Run `git commit` commands
- ❌ Run `git add` commands
- ❌ Modify the git repository state
- ❌ Stage or unstage files

### 1. Analyze Changes

**Review git changes (read-only analysis):**
```bash
git status
git diff --staged
```

**⚠️ These commands are for ANALYSIS ONLY. Do NOT stage files or create commits.**

**Review conversation context:**
- Read recent chat history for rationale and context
- Identify decisions made during implementation
- Note any constraints, requirements, or trade-offs discussed
- Consider user's explanation of what problem this solves

**Identify:**
- **Change complexity** (simple fix, medium refactor, complex architecture change?)
- Scope of changes (single file, multiple modules?)
- Type of change (feature, bugfix, refactor, docs?)
- Multiple logical changes? (Consider splitting)
- Rationale explained in conversation vs what's in code

**Determine detail level needed:**
- Simple/obvious changes: Concise 2-4 sentence explanation
- Medium complexity: 1-2 paragraph body
- Complex/non-obvious: Full structured explanation with sections

### 2. Ask Key Questions

Check if answers are already in the conversation history. If not, consider:

- What problem does this solve?
- What's the user-visible behavior change?
- Why is this approach better? (Only if not obvious)
- Are there side effects?
- Should this be split into multiple commits?
- Will someone years from now understand this?

**Extract from conversation:**
- User's description of the change
- Rationale discussed during implementation
- Trade-offs or alternatives considered
- Issues encountered and resolved

**Apply the "obvious test":** If something is immediately clear from reading the diff (like "changed X to Y"), don't repeat it in prose. Focus on the non-obvious: why the change was needed, what problem it solves, what alternatives were considered.

### 3. Draft Structure

**When --format=conventional:**

```
<type>(<scope>): <description>

[body with context and rationale]

[footer with metadata]
```

Types: feat, fix, docs, style, refactor, test, chore

**Default structure (no --format parameter):**

**Subject line** (50 chars):
```
[module:] <imperative verb> <what> [#ticket]
```

**Body paragraphs** (72 char wrap):

*For simple changes:*
- 2-4 sentences: problem, solution, key context

*For complex changes:*
1. Lead paragraph - The main point
2. Context - Before this change... (if not obvious)
3. Solution - Now... (if not obvious from diff)
4. Implications - Side effects, future work (if significant)

**Optional sections** (only when they add value):
- Changes: Bulleted list (only for multi-part changes where structure helps)
- Test Plan: Only for complex/critical testing scenarios
- Bug references and impact tags
- Trade-offs or alternatives (for non-obvious decisions)

### 4. Review and Refine

- [ ] Subject line ≤ 50 characters, no period?
- [ ] Blank line after subject?
- [ ] Body wrapped at 72 characters?
- [ ] Most important info first?
- [ ] Explains "why" not just "what"?
- [ ] Self-contained (no external dependencies)?
- [ ] Plain text readable (minimal formatting)?
- [ ] One logical change per commit?

## Format-Specific Guidelines

### When --format=conventional

Apply Conventional Commits format:
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:** feat, fix, docs, style, refactor, test, chore

**Structure:**
- Subject line: `<type>(<scope>): <description>` (max 50 chars for description part)
- Body: Still follow 72-char wrap, pyramid structure, explain why
- Footer: BREAKING CHANGE, issue references, etc.

**Important:** Even with Conventional Commits format, apply all the core principles from this guide:
- Explain the "why" not just the "what" (when non-obvious)
- Use pyramid structure (most important info first)
- Provide context: "Before this change..." vs "Now..." (when it adds clarity)
- Ensure self-containment
- Include rationale and side effects (when significant)
- Match detail level to change complexity

**Example:**
```
feat(auth): add OAuth2 token refresh

Implement automatic token refresh when access tokens expire.
Reduces user friction by maintaining sessions without re-login.

Before this change, users had to re-login every hour when access
tokens expired. Now the system automatically requests new tokens
using the refresh token.

BREAKING CHANGE: Auth middleware now requires refresh token storage
Closes-Bug: #9012
```

### Default Format (no --format parameter)

Follow the canonical structure from Simon Tatham and OpenStack:
- Descriptive subject line (50 chars max)
- No subject prefix (no `auth:`, `NFC:`, or similar)
- Blank line
- Body explaining context and rationale (72 char wrap)
- Optional metadata tags

This is the recommended format unless your project requires Conventional Commits.

## Tips for Success

### Split Large Commits

Sometimes clearer commits improve readability more than detailed explanations. Split into:
1. Boring mechanical changes (renaming, moving files)
2. Meaningful behavioral changes

### Use Git Rebase for History Cleanup

During development, use lighter commit messages as an "undo chain". Before pushing, use `git rebase -i` to restructure history and write proper messages.

### Incremental Improvement

Don't aim for perfection. Adopt one new principle at a time. Incremental improvements compound over months into substantially better documentation practices.

### The Goldilocks Principle

**Too little:** "Fix bug" - Useless years later
**Too much:** Multi-paragraph explanation of straightforward changes with obvious "Changes:" lists and routine "Test Plan:" sections
**Just right:** Enough context to understand the change without external resources, proportional to complexity

When in doubt, ask: "If I found this commit via git bisect in 2 years, what would I need to know that isn't obvious from the diff?"

### Plain Text Compatibility

Since not all tools render Markdown:
- Use physical line breaks for paragraph wrapping
- Avoid tables or complex formatting
- Backticks and underscores work acceptably
- Test readability in plain text viewer
