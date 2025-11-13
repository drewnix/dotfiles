# Git Aliases & Functions
# Git workflows and shortcuts

# ============================================================================
# Core Git Commands
# ============================================================================

alias g = git
alias gs = git status
alias gss = git status -s
alias ga = git add
alias gaa = git add --all
alias gap = git add -p
alias gc = git commit
alias gcm = git commit -m
alias gca = git commit -a
alias gcam = git commit -am
alias gcamend = git commit --amend
alias gcamendne = git commit --amend --no-edit

# ============================================================================
# Branching
# ============================================================================

alias gb = git branch
alias gba = git branch -a
alias gbd = git branch -d
alias gbD = git branch -D
alias gco = git checkout
alias gcob = git checkout -b
alias gcod = git checkout develop

# Checkout main (try main first, fallback to master)
def gcom [] {
    if (do -i { git checkout main } | complete | get exit_code) == 0 {
        print "Switched to main"
    } else {
        git checkout master
    }
}

# ============================================================================
# Diff
# ============================================================================

alias gd = git diff
alias gds = git diff --staged
alias gdw = git diff --word-diff
alias gdt = git difftool

# ============================================================================
# Logs
# ============================================================================

alias gl = git log
alias glo = git log --oneline
alias glog = git log --oneline --graph --decorate
alias gloga = git log --oneline --graph --decorate --all
alias gls = git log --stat
alias glp = git log -p

# ============================================================================
# Pull/Push
# ============================================================================

alias gp = git pull
alias gpr = git pull --rebase
alias gpu = git push
alias gpuf = git push --force-with-lease
alias gpuforce = git push --force

# Push and set upstream
def gpsup [] {
    let branch = (git branch --show-current)
    git push --set-upstream origin $branch
}

# ============================================================================
# Fetch/Merge
# ============================================================================

alias gf = git fetch
alias gfa = git fetch --all
alias gm = git merge
alias gma = git merge --abort
alias gmc = git merge --continue

# ============================================================================
# Rebase
# ============================================================================

alias gr = git rebase
alias gra = git rebase --abort
alias grc = git rebase --continue
alias gri = git rebase -i
alias grim = git rebase -i main

# ============================================================================
# Stash
# ============================================================================

alias gst = git stash
alias gsta = git stash apply
alias gstl = git stash list
alias gstp = git stash pop
alias gstd = git stash drop
alias gsts = git stash show -p

# ============================================================================
# Reset
# ============================================================================

alias grh = git reset HEAD
alias grhh = git reset --hard HEAD

# Reset to origin
def groh [] {
    let branch = (git branch --show-current)
    git reset --hard $"origin/($branch)"
}

# ============================================================================
# Clean
# ============================================================================

alias gclean = git clean -fd
alias gcleanx = git clean -fdx

# ============================================================================
# Remote
# ============================================================================

alias grem = git remote
alias gremv = git remote -v
alias grema = git remote add
alias gremrm = git remote remove

# ============================================================================
# Show
# ============================================================================

alias gsh = git show
alias gshw = git show --word-diff

# ============================================================================
# Tags
# ============================================================================

alias gt = git tag
alias gta = git tag -a
alias gtd = git tag -d
alias gtl = git tag -l

# ============================================================================
# Worktrees
# ============================================================================

alias gwt = git worktree
alias gwtls = git worktree list
alias gwtadd = git worktree add
alias gwtrm = git worktree remove

# ============================================================================
# Submodules
# ============================================================================

alias gsm = git submodule
alias gsmi = git submodule init
alias gsmu = git submodule update
alias gsmui = git submodule update --init
alias gsmuir = git submodule update --init --recursive

# ============================================================================
# Misc
# ============================================================================

alias gbl = git blame
alias gcp = git cherry-pick
alias gcpa = git cherry-pick --abort
alias gcpc = git cherry-pick --continue
alias gcount = git shortlog -sn
alias gwch = git whatchanged

# ============================================================================
# Git Helper Functions
# ============================================================================

# Quick commit all changes with message
def gcq [message: string] {
    git add --all
    git commit -m $message
}

# Commit and push
def gcp-push [message: string] {
    git add --all
    git commit -m $message
    git push
}

# Create new branch and switch to it
def gnb [branch: string] {
    git checkout -b $branch
}

# Delete branch locally and remotely
def gbd-all [branch: string] {
    git branch -d $branch
    git push origin --delete $branch
}

# Show files changed in last commit
def glast [] {
    git show --name-only HEAD
}

# Undo last commit (keep changes)
def gundo [] {
    git reset --soft HEAD~1
    print "Undid last commit (changes preserved)"
}

# Undo last commit (discard changes)
def gundohard [] {
    print "WARNING: This will discard all changes from the last commit"
    let response = (input "Are you sure? (yes/no): ")
    if $response == "yes" {
        git reset --hard HEAD~1
        print "Undid last commit and discarded changes"
    } else {
        print "Aborted"
    }
}

# Git log with file changes
def glf [file?: string] {
    if $file == null {
        git log --follow -p
    } else {
        git log --follow -p -- $file
    }
}

# Find commits by message
def gfind [search: string] {
    git log --all --grep=$search
}

# Show branches sorted by last commit
def gbrecent [] {
    git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'
    | lines
    | first 20
}

# Show contributors
def gcontrib [] {
    git shortlog -sn --all --no-merges
}

# Git repo info
def ginfo [] {
    let repo = (git rev-parse --show-toplevel | path basename)
    let branch = (git branch --show-current)
    let remote = (do -i { git remote get-url origin } | complete | get stdout | str trim)
    let last_commit = (git log -1 --format='%h - %s (%cr)')

    print "=== Git Repository Info ==="
    print $"Repository: ($repo)"
    print $"Branch: ($branch)"
    print $"Remote: ($remote)"
    print $"Last commit: ($last_commit)"
    print "\nStatus:"
    git status -s
}

# Update all submodules
def gsm-update-all [] {
    print "Updating all submodules..."
    git submodule update --init --recursive --remote
}

# Sync with main/master branch
def gsync [] {
    # Get main branch name
    let main_branch = (
        git remote show origin
        | lines
        | where $it =~ 'HEAD branch'
        | first
        | split row ' '
        | last
    )

    let current_branch = (git branch --show-current)

    print $"Syncing with ($main_branch)..."

    git fetch origin
    git checkout $main_branch
    git pull origin $main_branch

    if $current_branch != $main_branch {
        git checkout $current_branch
        print $"\nRebasing ($current_branch) on ($main_branch)..."
        git rebase $main_branch
    }
}

# Clean merged branches
def gclean-merged [] {
    print "Cleaning merged branches..."

    let merged = (
        git branch --merged
        | lines
        | where $it !~ '\*' and $it !~ 'main' and $it !~ 'master' and $it !~ 'develop'
        | each { str trim }
    )

    if ($merged | is-empty) {
        print "No merged branches to delete"
        return
    }

    print $"Found ($merged | length) merged branches:"
    $merged | each { |b| print $"  - ($b)" }

    for branch in $merged {
        git branch -d $branch
    }

    print "Done!"
}

# Create and push new tag
def gtag-push [
    tag: string
    message?: string
] {
    let msg = if $message == null {
        $"Release ($tag)"
    } else {
        $message
    }

    git tag -a $tag -m $msg
    git push origin $tag
    print $"Created and pushed tag: ($tag)"
}

# Show file history
def ghistory [file: string] {
    git log --follow --all -p -- $file
}

# Interactive rebase last N commits
def gri-last [count: int = 5] {
    git rebase -i $"HEAD~($count)"
}

# Squash last N commits
def gsquash [
    count: int
    message?: string
] {
    let msg = if $message == null {
        $"Squashed ($count) commits"
    } else {
        $message
    }

    git reset --soft $"HEAD~($count)"
    git commit -m $msg
    print $"Squashed ($count) commits"
}

# Show diff between branches
def gdiff-branch [branch1: string, branch2: string] {
    git diff $"($branch1)..($branch2)"
}

# Get current branch name
def git-current-branch [] {
    git branch --show-current
}

# Get main branch name (main or master)
def git-main-branch [] {
    let result = (do -i { git rev-parse --verify main } | complete)
    if $result.exit_code == 0 {
        "main"
    } else {
        "master"
    }
}

# List all git aliases
def git-aliases [] {
    help commands
    | where command_type == "alias"
    | where name =~ "^g"
    | select name expansion
}
