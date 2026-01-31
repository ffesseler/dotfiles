# GitHub App Integration

For teams that want automated skill generation with larger commit histories and PR automation, the [Skill Creator GitHub App](https://github.com/apps/skill-creator) provides additional features beyond the local analysis tool.

## Features

### Advanced Analysis
- Analyze 10k+ commits (vs 200 local limit)
- Cross-repository pattern detection
- Team-wide convention tracking
- Historical trend analysis

### Automation
- Auto-generate PRs with SKILL.md files
- Scheduled pattern analysis
- Automatic skill updates when patterns change
- Integration with CI/CD pipelines

### Collaboration
- Team-wide skill sharing
- Centralized pattern repository
- Review and approval workflows
- Version control for skills

## Installation

1. Visit [github.com/apps/skill-creator](https://github.com/apps/skill-creator)
2. Click "Install"
3. Select repositories to analyze
4. Grant required permissions

## Usage

Comment on any GitHub issue:

```
/skill-creator analyze
```

The app will:
1. Analyze the repository history
2. Generate SKILL.md files
3. Create a PR with the skills
4. Request review from maintainers

## Configuration

Create `.github/skill-creator.yml`:

```yaml
# Number of commits to analyze
commits: 1000

# Minimum pattern frequency to include
min_frequency: 0.1

# Output directory for skills
output_dir: .claude/skills

# Auto-merge if approved
auto_merge: false

# Reviewers to request
reviewers:
  - team-lead
  - senior-dev
```

## Local vs GitHub App

| Feature | Local Tool | GitHub App |
|---------|------------|------------|
| Commit limit | 200 | 10,000+ |
| Cost | Free | Free for public, paid for private |
| Setup | Python script | GitHub installation |
| Automation | Manual | Automated PRs |
| Team sharing | Manual | Built-in |
| CI/CD integration | Custom | Native |

## When to Use Local vs GitHub App

**Use Local Tool When:**
- Quick, one-off analysis needed
- Small repositories (<500 commits)
- Testing pattern detection
- No GitHub integration needed
- Working on private/offline repos

**Use GitHub App When:**
- Large repositories (1000+ commits)
- Team-wide skill sharing needed
- Automated skill updates desired
- CI/CD integration required
- Regular pattern analysis needed

## Migration Path

Start with local tool → Validate patterns → Install GitHub App for automation:

1. Run local analysis to test
2. Review and refine detected patterns
3. Install GitHub App once confident
4. Configure automation settings
5. Let app maintain skills going forward
