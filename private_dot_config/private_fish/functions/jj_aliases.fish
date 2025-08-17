# jujutsu aliases and functions

# Core workflow (inspired by your git aliases)
alias j "jj"                           # like your 'g' alias
alias jst "jj status"                  # like your 'gst'
alias jss "jj status -s"               # like your 'gss' (short status)
alias jsb "jj status"                  # like your 'gsb' (jj doesn't have -sb flag)

# Log and history (like your git log aliases)
alias jl "jj log"                      # like your 'gl' (but jj log, not pull)
alias jlog "jj log --graph"            # like your 'glog'
alias jloga "jj log --graph --all"     # like your 'gloga'
alias jlo "jj log --limit 10"          # like your 'glo' (oneline equivalent)
alias jcount "jj log --template 'author.name()' | sort | uniq -c | sort -nr"  # like your 'gcount'

# Diff commands (like your git diff aliases)
alias jd "jj diff"                     # like your 'gd'
alias jds "jj diff --stat"             # like your 'gds'
alias jsh "jj show"                    # like your 'gsh'

# File operations (like your git add/restore aliases)
alias jr "jj restore"                  # like your 'grs'
alias jrm "jj file untrack"            # like your 'grm'

# Bookmark management (like your git branch aliases)
alias jb "jj bookmark list -a"         # like your 'gb' (verbose branches)
alias jba "jj bookmark list -a"        # like your 'gba'
alias jbd "jj bookmark delete"         # like your 'gbd'
alias jbD "jj bookmark forget"         # like your 'gbD' (force delete)
alias jbc "jj bookmark create"         # like your 'gcb'
alias jco "jj edit"                    # like your 'gco' (checkout)
alias jcom "jj edit main"              # like your 'gcom'

# Commit operations (like your git commit aliases)
alias jc "jj commit"                   # like your 'gc'
alias jcm "jj commit -m"               # like your 'gcm'
alias jca "jj squash"                  # like your 'gca' (commit all - squash working copy)
alias jcam "jj squash -m"              # like your 'gcam'
alias jcan "jj squash --no-edit"       # like your 'gcan!'
alias jn "jj new"                      # create new change
alias jnm "jj new -m"                  # new change with message

# Rebase operations (like your git rebase aliases)
alias jreb "jj rebase"                 # like your 'grb'
alias jrebi "jj rebase -i"             # like your 'grbi' (interactive)
alias jrebm "jj rebase -d main"        # like your 'grbm'

# Push/pull operations (like your git push/pull aliases)
alias jp "jj git push"                 # like your 'gp'
alias jpu "jj git push --set-upstream" # like your 'gpu'
alias jf "jj git fetch"                # like your 'gf'
alias jfa "jj git fetch --all-remotes" # like your 'gfa'
alias jup "jj git fetch && jj rebase"  # like your 'gup' (pull rebase equivalent)

# Undo operations (like your git reset aliases)
alias ju "jj undo"                     # like your undo operations
alias jrhh "jj abandon @"              # like your 'grhh' (reset hard HEAD)

# Advanced operations
alias jfix "jj fix"                    # auto-fix issues in changes
alias jabs "jj absorb"                 # like git absorb
alias jsq "jj squash"                  # squash into parent
alias jsp "jj split"                   # split current change
alias jdup "jj duplicate"              # duplicate a change
alias jres "jj resolve"                # resolve conflicts

# Navigation (unique to jj)
alias jnext "jj next"                  # move to child
alias jprev "jj prev"                  # move to parent

# Git interop
alias jgi "jj git import"              # import git refs
alias jge "jj git export"              # export to git

# Operation log (unique to jj)
alias jop "jj operation log"           # view operation log
alias jopa "jj operation log --limit 20"  # view recent operations

# Clean operations (like your git clean aliases)
alias jclean "jj abandon @"            # abandon current change (like git clean)

# Remote operations (like your git remote aliases)
alias jgr "jj git remote list"         # like your 'gr'
alias jgra "jj git remote add"         # like your 'gra'

# Custom functions for common workflows (inspired by your git functions)

function jdesc
    # Describe current change with message (like your git commit workflow)
    if test (count $argv) -eq 0
        echo "Usage: jdesc <commit message>"
        return 1
    end
    jj describe -m "$argv"
end

function jnm
    # Create new change with message
    if test (count $argv) -eq 0
        echo "Usage: jnm <commit message>"
        return 1
    end
    jj new -m "$argv"
end

function jwip
    # Create a work-in-progress change (like your gwip)
    jj describe -m "WIP: $(date)"
    echo "Created WIP change. Use 'junwip' to continue working on it."
end

function junwip
    # Continue working on the most recent WIP change (like your gunwip)
    set wip_change (jj log --limit 50 --no-graph --template 'commit_id.short() ++ "\n"' | head -20 | while read id; jj show --summary $id | grep -q "WIP:" && echo $id && break; end)
    if test -n "$wip_change"
        jj edit $wip_change
        jj describe -m (jj log -r @ --template 'description' | sed 's/WIP: .*//')
        echo "Restored WIP change $wip_change"
    else
        echo "No WIP changes found"
    end
end

function jclean_all
    # Clean up abandoned changes (like your gclean!!)
    echo "This will abandon the current change and remove untracked files."
    echo "Type 'yes' to continue:"
    read -l confirm
    if test "$confirm" = "yes"
        jj abandon @
        echo "Current change abandoned. Use 'jj undo' if this was a mistake."
    else
        echo "Cancelled."
    end
end

function jbda
    # Delete all merged bookmarks (like your gbda)
    echo "Deleting merged bookmarks..."
    jj bookmark list | grep -v "main\|master" | awk '{print $1}' | while read bookmark
        jj bookmark delete $bookmark 2>/dev/null
    end
    echo "Merged bookmarks deleted."
end

function jgup
    # Git pull equivalent for current bookmark (like your ggu)
    set current_bookmark (jj log -r @ --template 'bookmarks.join(" ")')
    if test -n "$current_bookmark"
        jj git fetch
        jj rebase -d "origin/$current_bookmark"
    else
        echo "No bookmark set on current change"
    end
end

function jgpnp
    # Push and pull current bookmark (like your ggpnp)
    set current_bookmark (jj log -r @ --template 'bookmarks.join(" ")')
    if test -n "$current_bookmark"
        jj git push
        jj git fetch
        jj rebase -d "origin/$current_bookmark"
    else
        echo "No bookmark set on current change"
    end
end

function jggsup
    # Set upstream for current bookmark (like your ggsup)
    set current_bookmark (jj log -r @ --template 'bookmarks.join(" ")')
    if test -n "$current_bookmark"
        jj bookmark set $current_bookmark --revision @
        jj git push --set-upstream
    else
        echo "No bookmark set on current change"
    end
end

function jrt
    # Go to repository root (like your grt)
    cd (jj workspace root)
end

function jage
    # Show age of bookmarks (like your gbage)
    jj bookmark list --template 'name ++ ": " ++ target.timestamp().ago() ++ "\n"'
end

function jwch
    # Show what changed recently with diffs (like your gwch)
    jj log --limit 10 --patch
end

function jtest
    # Test staged changes only (like your gtest)
    if test (count $argv) -eq 0
        echo "Usage: jtest <command>"
        echo "Example: jtest make test"
        return 1
    end

    # In jj, we can test the current change
    echo "Running tests on current change..."
    eval $argv
end
