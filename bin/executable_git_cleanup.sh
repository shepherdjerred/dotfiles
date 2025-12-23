#!/bin/bash

set -euo pipefail

GIT_DIR="${1:-$HOME/git}"
DRY_RUN="${DRY_RUN:-false}"

echo "Scanning for worktrees in $GIT_DIR..."

# Find all git directories that are main worktrees (have a .git directory, not a file)
for repo in "$GIT_DIR"/*/; do
    [ -d "$repo" ] || continue

    # Skip if not a git repo
    [ -e "$repo/.git" ] || continue

    # Skip if this is a worktree (has .git file pointing elsewhere)
    if [ -f "$repo/.git" ]; then
        continue
    fi

    repo_name=$(basename "$repo")
    echo ""
    echo "=== $repo_name ==="

    cd "$repo"

    # Fetch latest to ensure we have up-to-date remote info
    git fetch --prune origin 2>/dev/null || true

    # Get the default branch
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

    # Get the main worktree path (first line of worktree list)
    main_worktree=$(git worktree list | head -1 | awk '{print $1}')

    # List all worktrees
    while IFS= read -r line; do
        worktree_path=$(echo "$line" | awk '{print $1}')
        branch=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p')

        # Skip the main worktree (always keep it)
        if [ "$worktree_path" = "$main_worktree" ]; then
            continue
        fi

        # Skip if no branch info (detached HEAD, etc)
        if [ -z "$branch" ]; then
            continue
        fi

        # Check if branch exists on remote
        remote_exists=$(git ls-remote --heads origin "$branch" 2>/dev/null | wc -l | tr -d ' ')

        # Check if branch is merged into default branch
        is_merged=false
        if git branch --merged "origin/$default_branch" 2>/dev/null | grep -q "^\s*$branch$\|^\*\s*$branch$"; then
            is_merged=true
        fi

        # If remote branch is gone or branch is merged, clean up
        if [ "$remote_exists" = "0" ] || [ "$is_merged" = "true" ]; then
            reason="merged"
            [ "$remote_exists" = "0" ] && reason="remote branch deleted"

            echo "  Removing worktree: $worktree_path ($branch - $reason)"

            if [ "$DRY_RUN" = "true" ]; then
                echo "    [DRY RUN] Would remove worktree and branch"
            else
                git worktree remove "$worktree_path" --force 2>/dev/null || rm -rf "$worktree_path"
                git branch -D "$branch" 2>/dev/null || true
                echo "    Removed"
            fi
        else
            echo "  Keeping worktree: $worktree_path ($branch - not merged)"
        fi
    done < <(git worktree list)

    # Prune any stale worktree references
    git worktree prune 2>/dev/null || true

    # Delete merged local branches (excluding default and current)
    merged_branches=$(git branch --merged "origin/$default_branch" 2>/dev/null | grep -v "^\*" | grep -v "^[[:space:]]*$default_branch$" | tr -d ' ' || true)
    if [ -n "$merged_branches" ]; then
        echo "  Cleaning merged local branches:"
        for branch in $merged_branches; do
            if [ "$DRY_RUN" = "true" ]; then
                echo "    [DRY RUN] Would delete branch: $branch"
            else
                git branch -d "$branch" 2>/dev/null && echo "    Deleted: $branch" || true
            fi
        done
    fi

    # Check for uncommitted changes
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        echo "  WARNING: Repo has uncommitted changes, skipping checkout/pull/stash-clear"
        continue
    fi

    # Checkout default branch
    current_branch=$(git branch --show-current 2>/dev/null || true)
    if [ "$current_branch" != "$default_branch" ]; then
        if [ "$DRY_RUN" = "true" ]; then
            echo "  [DRY RUN] Would checkout $default_branch (currently on $current_branch)"
        else
            git checkout "$default_branch" 2>/dev/null && echo "  Checked out $default_branch" || echo "  Failed to checkout $default_branch"
        fi
    fi

    # Pull latest
    if [ "$DRY_RUN" = "true" ]; then
        echo "  [DRY RUN] Would pull latest"
    else
        git pull 2>/dev/null && echo "  Pulled latest" || echo "  Failed to pull"
    fi

    # Drop stashes
    stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
    if [ "$stash_count" -gt 0 ]; then
        if [ "$DRY_RUN" = "true" ]; then
            echo "  [DRY RUN] Would drop $stash_count stash(es)"
        else
            git stash clear && echo "  Dropped $stash_count stash(es)"
        fi
    fi
done

echo ""
echo "Cleanup complete!"
