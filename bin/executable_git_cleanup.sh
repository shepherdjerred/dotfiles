#!/bin/bash
#
# Git Cleanup Script
#
# Cleans up Git repositories by:
# - Removing worktrees for merged/deleted branches
# - Deleting local branches that are merged
# - Checking GitHub PR status and cleaning branches with closed/merged PRs
# - Pruning stale remote tracking branches
# - Updating default branch and clearing stashes
#
# Usage:
#   git_cleanup.sh [directory]
#
# Environment variables:
#   DRY_RUN=true              - Preview changes without making them (default: false)
#   CHECK_PRS=true            - Check GitHub PR status (default: true, requires gh CLI)
#   CLEANUP_CLOSED_PRS=true   - Delete branches with closed PRs (default: true)
#
# Examples:
#   git_cleanup.sh                           # Clean ~/git
#   git_cleanup.sh ~/projects                # Clean ~/projects
#   DRY_RUN=true git_cleanup.sh              # Preview changes
#   CLEANUP_CLOSED_PRS=false git_cleanup.sh  # Keep branches with closed PRs
#

set -euo pipefail

# Show help
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    head -n 25 "$0" | grep "^#" | sed 's/^# \?//'
    exit 0
fi

GIT_DIR="${1:-$HOME/git}"
DRY_RUN="${DRY_RUN:-false}"
CHECK_PRS="${CHECK_PRS:-true}"
CLEANUP_CLOSED_PRS="${CLEANUP_CLOSED_PRS:-true}"

# Check if GitHub CLI is available
HAS_GH=false
if command -v gh &> /dev/null; then
    HAS_GH=true
    echo "GitHub CLI detected - will check PR status"
else
    echo "GitHub CLI not found - skipping PR status checks (install with 'brew install gh')"
    CHECK_PRS=false
fi

echo "Scanning for worktrees in $GIT_DIR..."
echo "Settings: DRY_RUN=$DRY_RUN, CHECK_PRS=$CHECK_PRS, CLEANUP_CLOSED_PRS=$CLEANUP_CLOSED_PRS"
echo ""

# Function to check PR status for a branch
# Returns: "merged", "closed", "open", "none", or "error"
check_pr_status() {
    local branch="$1"
    local repo_path="$2"

    if [ "$HAS_GH" = "false" ] || [ "$CHECK_PRS" = "false" ]; then
        echo "none"
        return
    fi

    cd "$repo_path"

    # Check if this is a GitHub repo
    local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ ! "$remote_url" =~ github\.com ]]; then
        echo "none"
        return
    fi

    # Get PR status for this branch
    local pr_state=$(gh pr list --head "$branch" --json state,closed --jq '.[0] | if .state == "MERGED" then "merged" elif .closed then "closed" elif .state == "OPEN" then "open" else "none" end' 2>/dev/null || echo "none")

    echo "$pr_state"
}

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

        # Check if branch has a remote tracking branch configured
        has_upstream=$(git config --get "branch.$branch.remote" 2>/dev/null || echo "")

        # Check if branch exists on remote
        remote_exists=$(git ls-remote --heads origin "$branch" 2>/dev/null | wc -l | tr -d ' ')

        # Check if branch is merged into default branch
        is_merged=false
        if git branch --merged "origin/$default_branch" 2>/dev/null | grep -q "^\s*$branch$\|^\*\s*$branch$"; then
            is_merged=true
        fi

        # Check PR status
        pr_status=$(check_pr_status "$branch" "$repo")

        # Determine if we should remove this worktree
        should_remove=false
        reason=""

        # Only consider it "deleted" if it HAD a remote tracking branch that's now gone
        if [ -n "$has_upstream" ] && [ "$remote_exists" = "0" ]; then
            should_remove=true
            reason="remote branch deleted"
        elif [ "$is_merged" = "true" ]; then
            should_remove=true
            reason="merged into $default_branch"
        elif [ "$pr_status" = "merged" ]; then
            should_remove=true
            reason="PR merged"
        elif [ "$pr_status" = "closed" ] && [ "$CLEANUP_CLOSED_PRS" = "true" ]; then
            should_remove=true
            reason="PR closed without merge"
        fi

        # Remove worktree if conditions are met
        if [ "$should_remove" = "true" ]; then
            echo "  Removing worktree: $worktree_path ($branch - $reason)"

            if [ "$DRY_RUN" = "true" ]; then
                echo "    [DRY RUN] Would remove worktree and branch"
            else
                git worktree remove "$worktree_path" --force 2>/dev/null || rm -rf "$worktree_path"
                git branch -D "$branch" 2>/dev/null || true
                echo "    Removed"
            fi
        else
            status_info="not merged"
            [ "$pr_status" != "none" ] && status_info="$status_info, PR: $pr_status"
            echo "  Keeping worktree: $worktree_path ($branch - $status_info)"
        fi
    done < <(git worktree list)

    # Prune any stale worktree references
    git worktree prune 2>/dev/null || true

    # Clean up remote tracking branches that no longer exist on remote
    echo "  Pruning remote tracking branches..."
    pruned=$(git remote prune origin --dry-run 2>/dev/null | grep "^\s*\*" | wc -l | tr -d ' \n' || echo "0")
    if [ "$pruned" -gt 0 ]; then
        if [ "$DRY_RUN" = "true" ]; then
            echo "    [DRY RUN] Would prune $pruned remote tracking branch(es)"
            git remote prune origin --dry-run 2>/dev/null | grep "^\s*\*" | sed 's/^/      /'
        else
            git remote prune origin 2>/dev/null && echo "    Pruned $pruned remote tracking branch(es)"
        fi
    else
        echo "    No stale remote tracking branches"
    fi

    # Delete merged local branches (excluding default and current)
    merged_branches=$(git branch --merged "origin/$default_branch" 2>/dev/null | grep -v "^\*" | grep -v "^[[:space:]]*$default_branch$" | tr -d ' ' || true)
    if [ -n "$merged_branches" ]; then
        echo "  Cleaning merged local branches:"
        for branch in $merged_branches; do
            if [ "$DRY_RUN" = "true" ]; then
                echo "    [DRY RUN] Would delete branch: $branch"
            else
                git branch -d "$branch" 2>/dev/null && echo "    Deleted: $branch (merged)" || true
            fi
        done
    fi

    # Check for branches with closed/merged PRs (even if not merged locally)
    if [ "$CHECK_PRS" = "true" ] && [ "$HAS_GH" = "true" ]; then
        echo "  Checking for branches with closed PRs..."

        # Get all local branches except current and default
        all_branches=$(git branch 2>/dev/null | grep -v "^\*" | grep -v "^[[:space:]]*$default_branch$" | tr -d ' ' || true)

        for branch in $all_branches; do
            # Skip if already processed as merged
            if echo "$merged_branches" | grep -q "^${branch}$"; then
                continue
            fi

            pr_status=$(check_pr_status "$branch" "$repo")

            should_delete=false
            delete_reason=""

            if [ "$pr_status" = "merged" ]; then
                should_delete=true
                delete_reason="PR merged"
            elif [ "$pr_status" = "closed" ] && [ "$CLEANUP_CLOSED_PRS" = "true" ]; then
                should_delete=true
                delete_reason="PR closed"
            fi

            if [ "$should_delete" = "true" ]; then
                if [ "$DRY_RUN" = "true" ]; then
                    echo "    [DRY RUN] Would delete branch: $branch ($delete_reason)"
                else
                    git branch -D "$branch" 2>/dev/null && echo "    Deleted: $branch ($delete_reason)" || true
                fi
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
