---
name: commit-message
description: Guide for writing clear, informative commit messages based on canonical sources (Simon Tatham's blog, OpenStack guidelines). Use when (1) creating git commits, (2) user asks about commit message writing, (3) reviewing or improving existing commit messages, (4) user wants guidance on commit message structure or content. Supports optional --format=conventional parameter for Conventional Commits (default is canonical format). Helps write messages that serve multiple audiences (users, reviewers, future developers) and remain valuable years later.
---

# Commit Message Writing Guide

This skill provides comprehensive guidance for writing high-quality commit messages based on two canonical sources: Simon Tatham's blog post on commit messages and the OpenStack GitCommitMessages wiki.

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
- No ending period
- Make each commit distinguishable
- Include ticket IDs if applicable
- Add module prefix for multi-area projects

**Body**
- Blank line after subject
- 72-character line wrap
- Lead with most important information (pyramid structure)
- Explain the "why" not just the "how"
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

### Self-Containment

Messages must be understandable years later without access to bug trackers, email threads, or external documentation. Include enough detail for independent review.

## Structure Guidelines

### Subject Line Format

Maximum 50 characters. Make each commit distinguishable from others.

**Patterns:**
```
Fix crash when user profile is incomplete (#44142)
auth: Switch libvirt get_cpu_info to config APIs
NFC: Extract user authentication logic to separate module
```

**Include:**
- Module/component prefix for multi-area projects
- Ticket/issue IDs in parentheses
- "NFC:" prefix for No Functional Change (refactoring)

**Avoid:**
- Generic descriptions: "Bug fix", "Updates", "Changes"
- Reusing ticket titles verbatim without context
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

Include these elements when relevant:

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

**Collaboration:**
- `Co-Authored-By: Name <email>` - Multiple contributors
- `Signed-off-by: Name <email>` - Developer Certificate of Origin

**Testing:**
- `Test Plan:` - Document manual testing performed

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
NFC: Extract user authentication logic to separate module

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
- Add composite index on (user_id, created_at)
- Use eager loading for activity associations
- Cache frequently accessed user preferences

Side effect: Database migration adds 50MB to index size, but
the performance improvement justifies this trade-off.

Test Plan: Load tested with 1000 concurrent users, verified
query performance in production staging
```

### Documentation Update

```
docs: Update API authentication examples

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

**Important:** When helping users write commit messages interactively, analyze BOTH the git changes AND the conversation history. The chat context often contains valuable rationale, design decisions, and explanations that should be captured in the commit message.

**After generating a commit message proposal, ALWAYS copy it to the clipboard** using one of these commands:
- macOS: `pbcopy`
- Linux: `xclip -selection clipboard` or `xsel --clipboard --input`
- Windows: `clip`

Example workflow:
```bash
# After crafting the commit message, copy it to clipboard
echo "Your commit message here" | pbcopy
```

This allows users to easily paste the message into `git commit` or review it in their editor.

### 1. Analyze Changes

**Review git changes:**
```bash
git status
git diff --staged
```

**Review conversation context:**
- Read recent chat history for rationale and context
- Identify decisions made during implementation
- Note any constraints, requirements, or trade-offs discussed
- Consider user's explanation of what problem this solves

**Identify:**
- Scope of changes (single file, multiple modules?)
- Type of change (feature, bugfix, refactor, docs?)
- Multiple logical changes? (Consider splitting)
- Rationale explained in conversation vs what's in code

### 2. Ask Key Questions

Check if answers are already in the conversation history. If not, consider:

- What problem does this solve?
- What's the user-visible behavior change?
- Why is this approach better?
- Are there side effects?
- Should this be split into multiple commits?
- Will someone years from now understand this?

**Extract from conversation:**
- User's description of the change
- Rationale discussed during implementation
- Trade-offs or alternatives considered
- Issues encountered and resolved

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
1. Lead paragraph - The main point
2. Context - Before this change...
3. Solution - Now...
4. Implications - Side effects, future work

**Metadata** (if applicable):
- Test Plan
- Bug references
- Impact tags

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
- Explain the "why" not just the "what"
- Use pyramid structure (most important info first)
- Provide context: "Before this change..." vs "Now..."
- Ensure self-containment
- Include rationale and side effects

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
- Optional module prefix
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

### Plain Text Compatibility

Since not all tools render Markdown:
- Use physical line breaks for paragraph wrapping
- Avoid tables or complex formatting
- Backticks and underscores work acceptably
- Test readability in plain text viewer

## References

Based on canonical sources:
- Simon Tatham's "How to write good commit messages" (chiark.greenend.org.uk/~sgtatham/quasiblog/commit-messages/)
- OpenStack GitCommitMessages wiki (wiki.openstack.org/wiki/GitCommitMessages)
