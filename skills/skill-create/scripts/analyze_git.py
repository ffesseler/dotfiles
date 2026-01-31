#!/usr/bin/env python3
"""
Analyze git repository history to extract coding patterns and workflows.
Generates data that can be used to create SKILL.md files.
"""

import subprocess
import sys
import json
from collections import defaultdict, Counter
from pathlib import Path
import re
import argparse


def run_git_command(cmd):
    """Run a git command and return the output."""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
            shell=False
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running git command: {e}", file=sys.stderr)
        return ""


def get_recent_commits(num_commits=200):
    """Get recent commit data including hash, message, date, and files."""
    cmd = [
        'git', 'log',
        f'-n{num_commits}',
        '--name-only',
        '--pretty=format:%H|%s|%ad|%an',
        '--date=short'
    ]
    output = run_git_command(cmd)
    
    commits = []
    current_commit = None
    
    for line in output.split('\n'):
        if '|' in line:
            # Commit metadata line
            parts = line.split('|')
            if len(parts) >= 3:
                current_commit = {
                    'hash': parts[0],
                    'message': parts[1],
                    'date': parts[2],
                    'author': parts[3] if len(parts) > 3 else '',
                    'files': []
                }
                commits.append(current_commit)
        elif line.strip() and current_commit:
            # File path line
            current_commit['files'].append(line.strip())
    
    return commits


def detect_commit_conventions(commits):
    """Detect commit message conventions."""
    patterns = {
        'conventional_commits': r'^(feat|fix|docs|chore|test|refactor|style|perf|ci|build)(\(.+?\))?:',
        'jira_tickets': r'[A-Z]+-\d+',
        'github_issues': r'#\d+',
        'pr_references': r'PR #\d+',
    }
    
    detected = defaultdict(list)
    pattern_counts = Counter()
    
    for commit in commits:
        msg = commit['message']
        
        for pattern_name, pattern in patterns.items():
            if re.search(pattern, msg):
                pattern_counts[pattern_name] += 1
                if len(detected[pattern_name]) < 5:  # Keep first 5 examples
                    detected[pattern_name].append(msg)
    
    return {
        'patterns': detected,
        'counts': dict(pattern_counts),
        'total_commits': len(commits)
    }


def analyze_file_patterns(commits):
    """Analyze file change patterns and architecture."""
    file_changes = Counter()
    extension_counts = Counter()
    directory_counts = Counter()
    file_cochanges = defaultdict(Counter)
    
    for commit in commits:
        files = commit['files']
        
        # Count individual file changes
        for file in files:
            file_changes[file] += 1
            
            # Track extensions
            if '.' in file:
                ext = file.split('.')[-1]
                extension_counts[ext] += 1
            
            # Track directories
            if '/' in file:
                directory = '/'.join(file.split('/')[:-1])
                directory_counts[directory] += 1
        
        # Track file co-changes
        for i, file1 in enumerate(files):
            for file2 in files[i+1:]:
                file_cochanges[file1][file2] += 1
    
    return {
        'most_changed_files': file_changes.most_common(20),
        'extension_counts': extension_counts.most_common(10),
        'active_directories': directory_counts.most_common(15),
        'file_cochanges': {
            file: dict(changes.most_common(5))
            for file, changes in list(file_cochanges.items())[:10]
        }
    }


def detect_workflows(commits):
    """Detect common workflows from sequential file changes."""
    workflows = []
    
    # Look for common patterns
    for commit in commits:
        files = set(commit['files'])
        msg = commit['message'].lower()
        
        # Test pattern
        test_files = [f for f in files if 'test' in f or 'spec' in f]
        source_files = [f for f in files if f not in test_files]
        
        if test_files and source_files:
            workflows.append({
                'type': 'test_with_source',
                'message': commit['message'],
                'files': list(files)
            })
        
        # Migration pattern
        if any('migration' in f.lower() or 'schema' in f.lower() for f in files):
            workflows.append({
                'type': 'database_migration',
                'message': commit['message'],
                'files': list(files)
            })
        
        # Documentation pattern
        doc_files = [f for f in files if f.endswith('.md') or 'docs' in f]
        if doc_files and source_files:
            workflows.append({
                'type': 'documented_change',
                'message': commit['message'],
                'files': list(files)
            })
    
    # Summarize workflows
    workflow_counts = Counter(w['type'] for w in workflows)
    workflow_examples = defaultdict(list)
    
    for workflow in workflows:
        wtype = workflow['type']
        if len(workflow_examples[wtype]) < 3:
            workflow_examples[wtype].append({
                'message': workflow['message'],
                'files': workflow['files'][:5]  # Limit files shown
            })
    
    return {
        'counts': dict(workflow_counts),
        'examples': dict(workflow_examples)
    }


def get_repo_info():
    """Get basic repository information."""
    repo_url = run_git_command(['git', 'config', '--get', 'remote.origin.url']).strip()
    
    # Extract repo name from URL
    repo_name = 'unknown'
    if repo_url:
        # Handle both SSH and HTTPS URLs
        match = re.search(r'[:/]([^/]+)/([^/]+?)(\.git)?$', repo_url)
        if match:
            repo_name = match.group(2)
    
    # Get branch name
    branch = run_git_command(['git', 'branch', '--show-current']).strip()
    
    return {
        'name': repo_name,
        'url': repo_url,
        'branch': branch
    }


def main():
    parser = argparse.ArgumentParser(
        description='Analyze git repository to extract patterns for SKILL.md generation'
    )
    parser.add_argument(
        '--commits',
        type=int,
        default=200,
        help='Number of recent commits to analyze (default: 200)'
    )
    parser.add_argument(
        '--output',
        type=str,
        help='Output JSON file path (default: stdout)'
    )
    parser.add_argument(
        '--repo-path',
        type=str,
        default='.',
        help='Path to git repository (default: current directory)'
    )
    
    args = parser.parse_args()
    
    # Change to repo directory if specified
    if args.repo_path != '.':
        try:
            import os
            os.chdir(args.repo_path)
        except Exception as e:
            print(f"Error changing to directory {args.repo_path}: {e}", file=sys.stderr)
            sys.exit(1)
    
    # Check if we're in a git repository
    if not Path('.git').exists():
        print("Error: Not a git repository", file=sys.stderr)
        sys.exit(1)
    
    print(f"Analyzing repository... (last {args.commits} commits)", file=sys.stderr)
    
    # Gather all analysis data
    repo_info = get_repo_info()
    commits = get_recent_commits(args.commits)
    
    if not commits:
        print("Error: No commits found", file=sys.stderr)
        sys.exit(1)
    
    commit_conventions = detect_commit_conventions(commits)
    file_patterns = analyze_file_patterns(commits)
    workflows = detect_workflows(commits)
    
    # Compile results
    analysis = {
        'repo': repo_info,
        'analysis_metadata': {
            'commits_analyzed': len(commits),
            'date_range': {
                'earliest': commits[-1]['date'] if commits else None,
                'latest': commits[0]['date'] if commits else None
            }
        },
        'commit_conventions': commit_conventions,
        'file_patterns': file_patterns,
        'workflows': workflows
    }
    
    # Output results
    output_json = json.dumps(analysis, indent=2)
    
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output_json)
        print(f"Analysis saved to {args.output}", file=sys.stderr)
    else:
        print(output_json)


if __name__ == '__main__':
    main()
