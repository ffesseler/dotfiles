---
name: skill-create
description: Analyze local git repository history to extract coding patterns, workflows, and conventions, then generate SKILL.md files that teach Claude your team's practices. Use when you need to (1) create skills from existing codebases, (2) document repository patterns and conventions, (3) extract coding workflows from git history, (4) generate development guidelines from actual practice, or (5) convert implicit team knowledge into explicit skill documentation.
---

# Skill Create - Git Pattern Analysis

Extract coding patterns from git history and generate SKILL.md files that teach Claude your team's practices.

## Quick Start

```bash
# Analyze current repository
python scripts/analyze_git.py

# Analyze last 100 commits
python scripts/analyze_git.py --commits 100

# Save analysis to file
python scripts/analyze_git.py --output analysis.json

# Analyze different repository
python scripts/analyze_git.py --repo-path /path/to/repo
```

## What It Does

The skill analyzes git repository history to:

1. **Detect Commit Conventions** - Identifies patterns like conventional commits, ticket references, PR mentions
2. **Analyze File Patterns** - Tracks most-changed files, file extensions, active directories
3. **Discover Workflows** - Detects recurring patterns like "test with source" or "database migrations"
4. **Extract Architecture** - Maps directory structure and file organization

## Workflow

### Step 1: Analyze Repository

Run the analysis script on your repository:

```bash
python scripts/analyze_git.py --commits 200 --output analysis.json
```

The script outputs JSON with:
- Repository information (name, URL, branch)
- Commit convention patterns
- File change patterns and co-changes
- Detected workflows
- Architecture insights

### Step 2: Review Analysis

Examine the JSON output to understand detected patterns:

```json
{
  "commit_conventions": {
    "patterns": {
      "conventional_commits": ["feat: add feature", "fix: bug fix"],
      "jira_tickets": ["PROJ-123 implement feature"]
    },
    "counts": {
      "conventional_commits": 150,
      "jira_tickets": 80
    }
  },
  "file_patterns": {
    "most_changed_files": [
      ["src/main.ts", 45],
      ["package.json", 30]
    ],
    "active_directories": [
      ["src/components", 120],
      ["src/utils", 85]
    ]
  },
  "workflows": {
    "counts": {
      "test_with_source": 45,
      "database_migration": 12
    }
  }
}
```

### Step 3: Generate SKILL.md

Based on the analysis, create a SKILL.md file that documents the patterns. Structure it as:

```markdown
---
name: {repo-name}-patterns
description: Coding patterns and conventions from {repo-name} repository
---

# {Repo Name} Development Patterns

## Commit Conventions

{List detected commit message patterns with examples}

## Code Architecture

{Describe directory structure and file organization}

## Common Workflows

{Document detected workflow patterns}

## File Conventions

{List naming conventions and file patterns}
```

### Step 4: Customize and Enhance

Enhance the generated SKILL.md with:

- Context that git history doesn't capture
- Why certain patterns exist
- When to deviate from patterns
- Links to related documentation

## Analysis Details

### Commit Convention Detection

The analyzer detects these patterns:

| Pattern | Regex | Example |
|---------|-------|---------|
| Conventional Commits | `^(feat\|fix\|docs\|chore\|test\|refactor):` | `feat: add login` |
| JIRA Tickets | `[A-Z]+-\d+` | `PROJ-123 fix bug` |
| GitHub Issues | `#\d+` | `Fix #42` |
| PR References | `PR #\d+` | `Merge PR #10` |

### Workflow Detection

Common workflows identified:

- **Test with Source**: Commits that change both source and test files
- **Database Migration**: Changes to schema or migration files
- **Documented Change**: Code changes accompanied by documentation updates

### File Pattern Analysis

Tracks:
- Most frequently changed files
- File extension distribution
- Active directories
- Files that change together (co-changes)

## Example: Creating a TypeScript Project Skill

```bash
# 1. Analyze the repository
cd ~/projects/my-typescript-app
python ~/.pi/agent/skills/skill-create/scripts/analyze_git.py --output analysis.json

# 2. Review analysis.json to see patterns

# 3. Create SKILL.md documenting patterns
cat > my-app-patterns.md << 'EOF'
---
name: my-app-patterns
description: Development patterns for my-typescript-app
---

# My App Development Patterns

## Commit Conventions

Use conventional commits:
- `feat:` - New features
- `fix:` - Bug fixes
- `test:` - Test updates
- `docs:` - Documentation

90% of commits follow this pattern (180/200 analyzed).

## Architecture

```
src/
├── components/     # React components (PascalCase.tsx)
├── hooks/          # Custom hooks (use*.ts)
├── utils/          # Utility functions
└── types/          # TypeScript definitions
```

## Workflows

### Adding a Component
1. Create `src/components/ComponentName.tsx`
2. Add tests in `src/components/__tests__/ComponentName.test.tsx`
3. Export from `src/components/index.ts`

Evidence: 45 commits follow this pattern

### Database Updates
1. Modify schema in `src/db/schema.ts`
2. Generate migration: `pnpm db:generate`
3. Apply migration: `pnpm db:migrate`

Evidence: 12 commits follow this pattern
EOF

# 4. Move to skills directory
mkdir -p ~/.pi/agent/skills/my-app-patterns
mv my-app-patterns.md ~/.pi/agent/skills/my-app-patterns/SKILL.md
```

## Tips

- **Start with 200 commits**: Good balance between coverage and signal-to-noise
- **Review the JSON**: Don't blindly trust the analysis - patterns need context
- **Add the "why"**: Git history shows what happened, not why
- **Focus on strong signals**: If a pattern appears in <10% of commits, it may not be significant
- **Iterate**: Test the generated skill and refine based on actual usage

## Related Tools

For more advanced features:
- [Skill Creator GitHub App](https://github.com/apps/skill-creator) - Analyze larger histories, auto-generate PRs
- See references/github-app.md for integration details

## Limitations

The analyzer can't detect:
- Unwritten conventions (code review practices, verbal agreements)
- Context behind decisions
- Deprecated patterns still present in history
- Nuanced exceptions to rules

Always review and enhance generated skills with human knowledge.
