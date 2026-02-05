---
name: worktree-workflow
description: |
  This skill should be used when the user mentions git worktree, asks about parallel development, isolated branch workflows, needs to switch contexts without branch switching, or starts new work requiring a separate working directory. Provides git worktree workflow guidance for isolated feature development and PR creation.
version: 1.0.0
---

# Git Worktree Workflow Agent

## What's New in Git Worktree & AI Agents (2025)

- **AI Agent Integration**: 4-5 parallel Claude Code agents working independently on different features
- **Complete Isolation**: Each worktree prevents agents from modifying wrong branches or interfering with each other
- **Structured Organization**: `./worktrees/feature/`, `./worktrees/bugfix/`, `./worktrees/review/` patterns for clarity
- **Production Adoption**: incident.io uses worktrees for parallel AI agent development
- **Emergency Hotfix Pattern**: Create worktree on release branch without disrupting ongoing development
- **Cleanup Best Practices**: Systematic removal of orphaned worktrees with `git worktree prune`
- **Meaningful Directory Names**: Avoid confusion when multiple agents or developers work simultaneously

## Overview

This agent teaches using Git worktrees to isolate changes in separate working directories, enabling parallel development without branch switching and creating clean PRs when complete. **Worktrees are particularly powerful for AI agent workflows**, where multiple autonomous agents can work on different features simultaneously without conflict.

## Core Concept

Git worktrees provide multiple working directories from the same repository:
- **Main worktree**: Your primary working directory (usually `main` or `master`)
- **Linked worktrees**: Additional directories for features/fixes, each on different branches
- **No branch switching**: Each worktree has its own branch checked out
- **Shared .git**: All worktrees share the same repository data

## CLI Commands

### Creating Worktrees

```bash
# Create worktree for new feature
git worktree add ../feature-auth feature/auth

# Create worktree with new branch from current HEAD
git worktree add -b fix/login-bug ../fix-login

# Create worktree from specific branch
git worktree add -b feature/api ../api-work origin/main

# Create worktree in subdirectory
git worktree add worktrees/feature-x -b feature/x
```

### Listing Worktrees

```bash
# List all worktrees
git worktree list

# List with more details
git worktree list --porcelain
```

### Removing Worktrees

```bash
# Remove worktree (deletes directory and unregisters)
git worktree remove ../feature-auth

# Remove even with uncommitted changes
git worktree remove --force ../feature-auth

# Clean up stale worktree references
git worktree prune
```

### Moving Between Worktrees

```bash
# Navigate to worktree
cd ../feature-auth

# Or use absolute path
cd ~/git/myproject-feature-auth

# Return to main worktree
cd ~/git/myproject
```

## Organized Worktree Layout

Keep worktrees outside the main repo or in a dedicated directory:

```bash
# Sibling layout (simple)
~/git/myproject/                    (main)
~/git/myproject-feature-auth/       (worktree)
~/git/myproject-fix-bug/            (worktree)

# Dedicated directory layout (organized)
~/worktrees/myproject/
  ├── feature-auth/
  ├── fix-bug-123/
  └── refactor-api/

# AI agent layout (structured by task type)
worktrees/
  ├── feature/agent-1-auth/
  ├── bugfix/agent-4-login-fix/
  └── review/human-review-pr-123/
```

## Best Practices

- **Consistent naming**: Match directory name to branch suffix (`feature/auth` -> `../feature-auth`)
- **Keep worktrees outside main repo**: Avoid nesting worktrees inside the main working tree
- **One branch per worktree**: Git enforces this -- the same branch cannot be checked out in two worktrees
- **Regular cleanup**: Run `git worktree prune` and remove merged worktrees weekly
- **Check before removing**: Always verify no uncommitted changes exist before `git worktree remove`
- **Meaningful names for agents**: Use `agent-1-auth` not `agent-1` or `temp` when running parallel AI agents
- **Structured categories**: Organize by task type (`feature/`, `bugfix/`, `review/`) for multi-agent setups

## Common Workflows

### Quick Bug Fix

1. Create worktree from main: `git worktree add ../fix-critical -b fix/critical-bug origin/main`
2. Work in it: `cd ../fix-critical`, make changes, commit
3. Push and PR: `git push -u origin fix/critical-bug && gh pr create --fill`
4. After merge: `git worktree remove ../fix-critical && git branch -d fix/critical-bug`

### Long-Running Feature

1. Create worktree: `git worktree add ../feature-big -b feature/big-feature origin/main`
2. Work over days, commit and push incrementally
3. Sync with main periodically: `git fetch origin && git rebase origin/main`
4. Create PR when ready: `gh pr create --fill`

### Parallel Features

1. Create multiple worktrees: one per feature branch
2. Switch between them with `cd` -- no branch checkout needed
3. Each has independent working state, staged files, and branch

### AI Agent Parallel Development

1. Set up structured worktree directories per agent (`worktrees/feature/agent-N-task/`)
2. Each agent works in complete isolation on its own branch
3. Agents commit and create PRs independently
4. Clean up worktrees after PRs merge

## Troubleshooting

### "Cannot remove worktree with uncommitted changes"

```bash
# Option 1: Commit or stash changes first
cd ../feature-auth && git stash

# Option 2: Force remove (loses changes!)
git worktree remove --force ../feature-auth
```

### "Branch already checked out"

```bash
# Same branch can't exist in multiple worktrees
# Solution: Create a new branch from the existing one
git worktree add ../feature-auth-v2 -b feature/auth-v2 feature/auth
```

### Worktree directory deleted manually

```bash
# Clean up stale references
git worktree prune
git worktree list  # Verify
```

## When to Ask for Help

Ask the user for clarification when:
- Worktree layout preferences (flat vs nested, naming conventions)
- How to handle merge conflicts during rebase
- Whether to keep or remove worktree after PR merge
- Multiple people working on same repository with worktrees
- Integration with IDEs or editors for worktree navigation

## Additional Resources

For full shell scripts and detailed patterns, see the reference files:

- **[Workflow Scripts](references/workflow-scripts.md)**: Complete shell scripts including `start-work.sh`, `pr-from-worktree.sh`, `complete-work.sh`, `switch-worktree.sh`, `worktree-status.sh`, `cleanup-merged-worktrees.sh`, `find-orphaned-worktrees.sh`, and the combined `feature.sh` start-to-PR script
- **[AI Agent Workflows](references/ai-agent-workflows.md)**: The incident.io case study, structured directory organization for agents, `setup-ai-agent-worktree.sh`, isolation benefits, emergency hotfix pattern, `cleanup-ai-agent-worktree.sh`, and best practices for AI agent workflows
