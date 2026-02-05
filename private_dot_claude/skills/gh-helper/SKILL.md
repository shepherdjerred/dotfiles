---
name: gh-helper
description: |
  This skill should be used when the user mentions GitHub, repositories, issues, PRs,
  gh command, code search, commits, or file contents on GitHub. Provides complete
  GitHub CLI guidance for repos, issues, pull requests, code search, actions, releases,
  and file management via the gh CLI.
version: 1.0.0
---

# GitHub CLI Helper Agent

## Overview

Complete GitHub operations via `gh` CLI and GitHub API. This skill replaces GitHub MCP server functionality, providing CLI/API equivalents for all operations.

## MCP Tool Equivalents Reference

| MCP Tool | CLI/API Equivalent |
|----------|-------------------|
| `create_or_update_file` | `gh api -X PUT /repos/{owner}/{repo}/contents/{path}` |
| `search_repositories` | `gh search repos <query>` |
| `create_repository` | `gh repo create <name>` |
| `get_file_contents` | `gh api /repos/{owner}/{repo}/contents/{path}` |
| `push_files` | `git add && git commit && git push` |
| `create_issue` | `gh issue create` |
| `create_pull_request` | `gh pr create` |
| `fork_repository` | `gh repo fork` |
| `create_branch` | `gh api -X POST /repos/{owner}/{repo}/git/refs` |
| `list_commits` | `gh api /repos/{owner}/{repo}/commits` |
| `list_issues` | `gh issue list` |
| `update_issue` | `gh issue edit` |
| `add_issue_comment` | `gh issue comment` |
| `search_code` | `gh search code <query>` |
| `search_issues` | `gh search issues <query>` |
| `search_users` | `gh api /search/users?q=<query>` |
| `get_issue` | `gh issue view <number>` |
| `get_pull_request` | `gh pr view <number>` |
| `list_pull_requests` | `gh pr list` |
| `create_pull_request_review` | `gh pr review` |
| `merge_pull_request` | `gh pr merge` |
| `get_pull_request_files` | `gh api /repos/{owner}/{repo}/pulls/{number}/files` |
| `get_pull_request_status` | `gh pr checks` |
| `update_pull_request_branch` | `gh api -X PUT /repos/{owner}/{repo}/pulls/{number}/update-branch` |
| `get_pull_request_comments` | `gh api /repos/{owner}/{repo}/pulls/{number}/comments` |
| `get_pull_request_reviews` | `gh api /repos/{owner}/{repo}/pulls/{number}/reviews` |

## Auto-Approved Commands

Safe read-only commands:
- `gh repo view`, `gh repo list`
- `gh issue list`, `gh issue view`
- `gh pr list`, `gh pr view`, `gh pr diff`, `gh pr checks`
- `gh run list`, `gh run view`, `gh run watch`
- `gh workflow list`, `gh workflow view`
- `gh release list`, `gh release view`
- `gh search repos`, `gh search code`, `gh search issues`
- `gh status`

---

## Operation Categories

**Repository Operations** -- Search, create, and fork repositories. Get and update file contents via the API. Push multiple files, create branches, and list commits. See `references/repo-operations.md` for full command examples.

**Issue Operations** -- List, view, create, update, close, and reopen issues. Add comments, manage labels and assignees, filter by milestone or state, and search across repositories. See `references/issue-operations.md` for full command examples.

**Pull Request Operations** -- List, view, create, review, and merge pull requests. Check CI status, view diffs and changed files, add review comments, update branches, and configure auto-merge. See `references/pr-operations.md` for full command examples.

**Code Search** -- Search code across GitHub with language, repo, and filename filters. Search users by name, location, or email domain via the API.

**GitHub Actions** -- List workflows, view and watch runs, trigger workflow_dispatch events with inputs, cancel or rerun failed jobs.

**Releases** -- List, view, and create releases with auto-generated notes, draft/prerelease flags, and asset uploads.

**Authentication & Advanced API** -- Login, check status, switch accounts, set editor, create aliases, and open any repo page in the browser. Use `gh api` for arbitrary REST or GraphQL requests with pagination and jq filtering.

See `references/actions-releases-api.md` for full command examples on code search, actions, releases, auth, and API usage.

---

## Common Workflows

### Complete PR Workflow

```bash
# Create branch and make changes
git checkout -b feature/new-thing
# ... make changes ...
git add . && git commit -m "Add new feature"
git push -u origin feature/new-thing

# Create PR
gh pr create --fill

# Check status and merge
gh pr checks --watch
gh pr merge --squash --delete-branch
```

### Daily PR Review Routine

```bash
# PRs waiting for your review
gh pr list --search "review-requested:@me"

# Your open PRs
gh pr list --author @me

# Check PR status
gh pr checks --watch
```

### Release Workflow

```bash
# Create and push tag
git tag v1.0.0
git push origin v1.0.0

# Create release with auto-generated notes
gh release create v1.0.0 --generate-notes

# Upload release assets
gh release upload v1.0.0 ./dist/*.tar.gz
```

---

## When to Ask for Help

Ask the user for clarification when:
- Repository owner/name is ambiguous
- Multiple PRs or issues match criteria
- Authentication or permissions issues arise
- Workflow involves destructive operations (force push, delete)
- Need to determine correct branch or ref

---

## Additional Resources

For detailed command examples and full syntax reference, see:
- `references/repo-operations.md` -- Repository search, create, fork, file contents, branches, commits
- `references/issue-operations.md` -- Issue listing, creation, editing, comments, search
- `references/pr-operations.md` -- PR listing, creation, reviews, merging, branch updates
- `references/actions-releases-api.md` -- Code search, GitHub Actions, releases, authentication, advanced API
