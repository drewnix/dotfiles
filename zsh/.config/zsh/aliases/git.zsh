# ╔══════════════════════════════════════════════════════════════╗
# ║ Git Aliases & Functions                                      ║
# ╚══════════════════════════════════════════════════════════════╝

# Core git commands
alias g='git'
alias gs='git status'
alias gss='git status -s'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -a'
alias gcam='git commit -am'
alias gcamend='git commit --amend'
alias gcamendne='git commit --amend --no-edit'

# Branching
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout main 2>/dev/null || git checkout master'
alias gcod='git checkout develop'

# Diff
alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gdt='git difftool'

# Logs
alias gl='git log'
alias glo='git log --oneline'
alias glog='git log --oneline --graph --decorate'
alias gloga='git log --oneline --graph --decorate --all'
alias gls='git log --stat'
alias glp='git log -p'

# Pull/Push
alias gp='git pull'
alias gpr='git pull --rebase'
alias gpu='git push'
alias gpuf='git push --force-with-lease'
alias gpuforce='git push --force'
alias gpsup='git push --set-upstream origin $(git branch --show-current)'

# Fetch/Merge
alias gf='git fetch'
alias gfa='git fetch --all'
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'

# Rebase
alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase -i'
alias grim='git rebase -i main'

# Stash
alias gst='git stash'
alias gsta='git stash apply'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gstd='git stash drop'
alias gsts='git stash show -p'

# Reset
alias grh='git reset HEAD'
alias grhh='git reset --hard HEAD'
alias groh='git reset --hard origin/$(git branch --show-current)'

# Clean
alias gclean='git clean -fd'
alias gcleanx='git clean -fdx'

# Remote
alias grem='git remote'
alias gremv='git remote -v'
alias grema='git remote add'
alias gremrm='git remote remove'

# Show
alias gsh='git show'
alias gshw='git show --word-diff'

# Tags
alias gt='git tag'
alias gta='git tag -a'
alias gtd='git tag -d'
alias gtl='git tag -l'

# Worktrees
alias gwt='git worktree'
alias gwtls='git worktree list'
alias gwtadd='git worktree add'
alias gwtrm='git worktree remove'

# Submodules
alias gsm='git submodule'
alias gsmi='git submodule init'
alias gsmu='git submodule update'
alias gsmui='git submodule update --init'
alias gsmuir='git submodule update --init --recursive'

# Misc
alias gbl='git blame'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcount='git shortlog -sn'
alias gwch='git whatchanged'

# ╔══════════════════════════════════════════════════════════════╗
# ║ Git Helper Functions                                         ║
# ╚══════════════════════════════════════════════════════════════╝

# Quick commit all changes with message
gcq() {
  if [ -z "$1" ]; then
    echo "Usage: gcq <commit-message>"
    return 1
  fi
  git add --all && git commit -m "$1"
}

# Commit and push
gcp-push() {
  if [ -z "$1" ]; then
    echo "Usage: gcp-push <commit-message>"
    return 1
  fi
  git add --all && git commit -m "$1" && git push
}

# Create new branch and switch to it
gnb() {
  if [ -z "$1" ]; then
    echo "Usage: gnb <branch-name>"
    return 1
  fi
  git checkout -b "$1"
}

# Delete branch locally and remotely
gbd-all() {
  if [ -z "$1" ]; then
    echo "Usage: gbd-all <branch-name>"
    return 1
  fi
  git branch -d "$1"
  git push origin --delete "$1"
}

# Show files changed in last commit
glast() {
  git show --name-only HEAD
}

# Undo last commit (keep changes)
gundo() {
  git reset --soft HEAD~1
}

# Undo last commit (discard changes)
gundohard() {
  echo "WARNING: This will discard all changes from the last commit"
  read "response?Are you sure? (yes/no): "
  if [ "$response" = "yes" ]; then
    git reset --hard HEAD~1
  else
    echo "Aborted"
  fi
}

# Git log with file changes
glf() {
  if [ -z "$1" ]; then
    git log --follow -p
  else
    git log --follow -p -- "$1"
  fi
}

# Find commits by message
gfind() {
  if [ -z "$1" ]; then
    echo "Usage: gfind <search-term>"
    return 1
  fi
  git log --all --grep="$1"
}

# Show branches sorted by last commit
gbrecent() {
  git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)' | head -20
}

# Show contributors
gcontrib() {
  git shortlog -sn --all --no-merges
}

# Git repo info
ginfo() {
  echo "Repository: $(basename $(git rev-parse --show-toplevel))"
  echo "Branch: $(git branch --show-current)"
  echo "Remote: $(git remote get-url origin 2>/dev/null || echo 'No remote')"
  echo "Last commit: $(git log -1 --format='%h - %s (%cr)' 2>/dev/null)"
  echo "\nStatus:"
  git status -s
}

# Update all submodules
gsm-update-all() {
  echo "Updating all submodules..."
  git submodule update --init --recursive --remote
}

# Sync with main/master branch
gsync() {
  local main_branch=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
  if [ -z "$main_branch" ]; then
    main_branch="main"
  fi

  echo "Syncing with $main_branch..."
  local current_branch=$(git branch --show-current)

  git fetch origin
  git checkout $main_branch
  git pull origin $main_branch

  if [ "$current_branch" != "$main_branch" ]; then
    git checkout $current_branch
    echo "\nRebasing $current_branch on $main_branch..."
    git rebase $main_branch
  fi
}

# Clean merged branches
gclean-merged() {
  echo "Cleaning merged branches..."
  git branch --merged | grep -v '\*\|main\|master\|develop' | xargs -n 1 git branch -d
}

# Create and push new tag
gtag-push() {
  if [ -z "$1" ]; then
    echo "Usage: gtag-push <tag-name> [message]"
    return 1
  fi

  local tag_name=$1
  local message="${2:-Release $tag_name}"

  git tag -a "$tag_name" -m "$message"
  git push origin "$tag_name"
  echo "Created and pushed tag: $tag_name"
}

# Show file history
ghistory() {
  if [ -z "$1" ]; then
    echo "Usage: ghistory <file-path>"
    return 1
  fi
  git log --follow --all -p -- "$1"
}

# Interactive rebase last N commits
gri-last() {
  local count="${1:-5}"
  git rebase -i HEAD~$count
}

# Squash last N commits
gsquash() {
  if [ -z "$1" ]; then
    echo "Usage: gsquash <number-of-commits> [new-message]"
    return 1
  fi

  local count=$1
  local message="${2:-Squashed $count commits}"

  git reset --soft HEAD~$count
  git commit -m "$message"
}

# Show diff between branches
gdiff-branch() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: gdiff-branch <branch1> <branch2>"
    return 1
  fi
  git diff $1..$2
}
