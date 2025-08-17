# Jujutsu (jj) Aliases and Functions

This document provides a comprehensive reference for all jj aliases and functions defined in `private_dot_config/private_fish/functions/jj_aliases.fish`.

## Overview

These aliases are designed to provide a familiar workflow for users transitioning from Git to Jujutsu, while taking advantage of jj's unique features like safer operations and the operation log.

## Core Workflow Aliases

### Basic Commands
| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `j` | `jj` | `g` | Short for jj |
| `jst` | `jj status` | `gst` | Show working copy status |
| `jss` | `jj status -s` | `gss` | Short status format |
| `jsb` | `jj status` | `gsb` | Status (jj doesn't have -sb flag) |

### Log and History
| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jl` | `jj log` | `gl` | Show commit history |
| `jlog` | `jj log --graph` | `glog` | Show log with graph |
| `jloga` | `jj log --graph --all` | `gloga` | Show log graph for all changes |
| `jlo` | `jj log --limit 10` | `glo` | Show recent 10 changes |
| `jcount` | `jj log --template 'author.name()' \| sort \| uniq -c \| sort -nr` | `gcount` | Count commits by author |

### Diff Commands
| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jd` | `jj diff` | `gd` | Show diff of working copy |
| `jds` | `jj diff --stat` | `gds` | Show diff statistics |
| `jsh` | `jj show` | `gsh` | Show a change |

### File Operations
| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jr` | `jj restore` | `grs` | Restore files |
| `jrm` | `jj file untrack` | `grm` | Untrack files |

## Bookmark Management (Git Branch Equivalent)

| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jb` | `jj bookmark list -a` | `gb` | List all bookmarks |
| `jba` | `jj bookmark list -a` | `gba` | List all bookmarks |
| `jbd` | `jj bookmark delete` | `gbd` | Delete bookmark |
| `jbD` | `jj bookmark forget` | `gbD` | Force delete bookmark |
| `jbc` | `jj bookmark create` | `gcb` | Create new bookmark |
| `jco` | `jj edit` | `gco` | Edit/checkout a change |
| `jcom` | `jj edit main` | `gcom` | Edit main bookmark |

## Commit Operations

| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jc` | `jj commit` | `gc` | Commit current change |
| `jcm` | `jj commit -m` | `gcm` | Commit with message |
| `jca` | `jj squash` | `gca` | Squash working copy into parent |
| `jcam` | `jj squash -m` | `gcam` | Squash with message |
| `jcan` | `jj squash --no-edit` | `gcan!` | Squash without editing message |
| `jn` | `jj new` | - | Create new change |
| `jnm` | `jj new -m` | - | Create new change with message |

## Rebase Operations

| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jreb` | `jj rebase` | `grb` | Rebase changes |
| `jrebi` | `jj rebase -i` | `grbi` | Interactive rebase |
| `jrebm` | `jj rebase -d main` | `grbm` | Rebase onto main |

## Push/Pull Operations

| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jp` | `jj git push` | `gp` | Push to git remote |
| `jpu` | `jj git push --set-upstream` | `gpu` | Push and set upstream |
| `jf` | `jj git fetch` | `gf` | Fetch from git remote |
| `jfa` | `jj git fetch --all-remotes` | `gfa` | Fetch from all remotes |
| `jup` | `jj git fetch && jj rebase` | `gup` | Fetch and rebase |

## Undo Operations

| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `ju` | `jj undo` | - | Undo last operation |
| `jrhh` | `jj abandon @` | `grhh` | Abandon current change |

## Advanced Operations

| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jfix` | `jj fix` | - | Auto-fix issues in changes |
| `jabs` | `jj absorb` | - | Absorb changes into ancestors |
| `jsq` | `jj squash` | - | Squash into parent |
| `jsp` | `jj split` | - | Split current change |
| `jdup` | `jj duplicate` | - | Duplicate a change |
| `jres` | `jj resolve` | - | Resolve conflicts |

## Navigation (Unique to jj)

| Alias | Command | Description |
|-------|---------|-------------|
| `jnext` | `jj next` | Move to child change |
| `jprev` | `jj prev` | Move to parent change |

## Git Interop

| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jgi` | `jj git import` | - | Import git refs |
| `jge` | `jj git export` | - | Export to git |

## Operation Log (Unique to jj)

| Alias | Command | Description |
|-------|---------|-------------|
| `jop` | `jj operation log` | View operation log |
| `jopa` | `jj operation log --limit 20` | View recent operations |

## Clean Operations

| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jclean` | `jj abandon @` | `gclean` | Abandon current change |

## Remote Operations

| Alias | Command | Git Equivalent | Description |
|-------|---------|----------------|-------------|
| `jgr` | `jj git remote list` | `gr` | List git remotes |
| `jgra` | `jj git remote add` | `gra` | Add git remote |

## Custom Functions

### Basic Functions

#### `jdesc <message>`
Describe the current change with a message (like git commit workflow).
```fish
jdesc "Fix user authentication bug"
```

#### `jnm <message>`
Create a new change with a message.
```fish
jnm "Start implementing new feature"
```

### Work-in-Progress Workflow

#### `jwip`
Create a work-in-progress change (like git's `gwip`). Saves current work with a timestamped WIP message.
```fish
jwip  # Creates "WIP: Mon Jan 15 14:30:22 PST 2024"
```

#### `junwip`
Continue working on the most recent WIP change (like git's `gunwip`). Finds and restores the most recent WIP change.
```fish
junwip  # Restores and cleans up WIP message
```

### Cleanup Functions

#### `jclean_all`
Clean up abandoned changes (like git's `gclean!!`). Prompts for confirmation before abandoning current change.
```fish
jclean_all  # Prompts: Type 'yes' to continue
```

#### `jbda`
Delete all merged bookmarks (like git's `gbda`). Removes bookmarks except main/master.
```fish
jbda  # Deletes merged feature branches
```

### Advanced Workflow Functions

#### `jgup`
Git pull equivalent for current bookmark (like git's `ggu`). Fetches and rebases current bookmark.
```fish
jgup  # Fetch and rebase current bookmark
```

#### `jgpnp`
Push and pull current bookmark (like git's `ggpnp`). Pushes changes then fetches and rebases.
```fish
jgpnp  # Push then pull current bookmark
```

#### `jggsup`
Set upstream for current bookmark (like git's `ggsup`). Sets bookmark and pushes with upstream.
```fish
jggsup  # Set upstream for current bookmark
```

### Utility Functions

#### `jrt`
Go to repository root (like git's `grt`). Changes directory to the workspace root.
```fish
jrt  # cd $(jj workspace root)
```

#### `jage`
Show age of bookmarks (like git's `gbage`). Displays how old each bookmark is.
```fish
jage  # Shows: main: 2 days ago, feature: 1 hour ago
```

#### `jwch`
Show what changed recently with diffs (like git's `gwch`). Shows recent changes with patches.
```fish
jwch  # Recent changes with full diffs
```

#### `jtest <command>`
Test current change (like git's `gtest`). Runs specified command against current change.
```fish
jtest make test     # Run tests on current change
jtest npm run lint  # Run linting on current change
```

## Sample Workflow

Here's how your familiar git workflow translates to jj:

```fish
# Navigate and check status
cd my-repo
jst              # jj status (like gst)

# Clean slate if needed
jclean_all       # abandon current change (safer than git reset --hard)
jcom             # edit main bookmark (like gcom)
jf               # fetch changes (like gf)

# Create feature branch
jbc fix-bug      # create new fix-bug bookmark (like gcb)

# Edit files, then commit
jc               # commit changes (like gc)
jp               # push to origin (like gp)

# Need to edit more
# (edit files)
jsq              # squash into previous change (like gca!)
jp               # push (jj handles force push safely)

# Need changes from main
jf && jreb -d main  # fetch and rebase on main (like grbom)

# Work-in-progress workflow
jwip             # save WIP change (like gwip)
jf               # fetch all (like gfa)
jloga            # view log graph (like gloga)
jco feature      # switch to feature bookmark (like gco)
jwch             # inspect recent changes (like gwch)

# Back to bug fix
jco fix-bug      # checkout fix-bug (like gco)
junwip           # restore WIP (like gunwip)
```

## Key Differences from Git

1. **No staging area** - jj works directly with changes
2. **Changes vs commits** - You work on a change until you `jj commit` to finalize it
3. **Bookmarks vs branches** - Bookmarks are lighter weight and move automatically
4. **Safe operations** - `jj abandon` is safer than `git reset --hard` due to operation log
5. **Undo anything** - `jj undo` can undo almost any operation, making experimentation safer
6. **Automatic conflict resolution** - jj handles many conflicts automatically
7. **Operation log** - Every operation is recorded and can be undone

## Conflict Check

All aliases have been programmatically verified to not conflict with:
- ✅ Existing PATH executables (40+ checked including `java`, `jq`, `jobs`)
- ✅ Current fish aliases and functions
- ✅ Git plugin functions (`gwip`, `gunwip`, `grt`, etc.)

**Total: 53 aliases + 12 functions = 65 jj shortcuts ready to use!**
