###############################################################################
# 20-git-aliases.sh — Public Git command aliases and wrappers
#
# Purpose:
#   Define user-friendly Git helper aliases that streamline common workflows.
#   This includes:
#     • Safe functional wrappers that add confirmations and better UX.
#     • Concise Git command shortcuts for everyday operations.
#
# Structure:
#   - Wrapper aliases (e.g., `push-all`, `tag-push`, `undo-last-commit`)
#     expose the logic implemented in 10-functions.sh.
#   - Git command shortcuts (e.g., `gc`, `gs`, `gl`, `gca`, etc.)
#     directly invoke standard Git commands for speed and consistency.
#
# Conventions:
#   - Wrapper functions use underscored names internally (POSIX-safe).
#   - Public aliases use hyphenated names for clarity and consistency.
#   - The full Git shortcuts list is grouped under one section for readability.
#
# Dependencies:
#   - Requires 10-functions.sh for the wrapper implementations.
#   - Requires 00-config.sh to include these aliases in the “Git” group.
#
# Example usage:
#   push-all "Fix broken deployment"    # Stage, commit, and confirm push
#   tag-push v2.0.1 "Release v2.0.1"    # Create and push annotated tag
#   undo-last-commit                    # Undo last commit but keep staged
#   gs                                   # Show short Git status
#   gl                                   # Compact decorated log graph
###############################################################################

# @group: Git
# @keys: git

# -----------------------------------------------------------------------------
# push-all — Add, commit, and optionally push all changes (with confirmation)
# Wrapper: push_all_wrapper()
# Description:
#   Stages all modified files, commits with the given message, and asks before
#   pushing to the remote branch. Useful for safety-conscious workflows.
# -----------------------------------------------------------------------------
# @hint <message>
alias push-all='push_all_wrapper'

# -----------------------------------------------------------------------------
# tag-push — Create and push an annotated Git tag
# Wrapper: tag_push_wrapper()
# Description:
#   Creates a new annotated tag (-a) with an optional message, then pushes all
#   tags to the remote. Automatically names the tag if no message is supplied.
# -----------------------------------------------------------------------------
# @hint <tag> [message]
alias tag-push='tag_push_wrapper'

# -----------------------------------------------------------------------------
# undo-last-commit — Undo last commit but keep changes staged
# Wrapper: undo_last_commit_wrapper()
# Description:
#   Performs a soft reset to the previous commit (HEAD~1) while retaining
#   staged changes. Handy for quickly correcting a commit message or redoing
#   a commit without losing progress.
# -----------------------------------------------------------------------------
alias undo-last-commit='undo_last_commit_wrapper'

###############################################################################
# Git command shortcuts
#
# Description:
#   Simple, readable shorthand aliases for common Git commands. These directly
#   invoke Git, providing faster access for frequent operations.
###############################################################################

# Clone a repository
alias gc='git clone'

# Show compact Git status (short format + branch summary)
alias gs='git status -sb'

# Show compact decorated log graph for all branches
alias gl='git log --oneline --graph --decorate --all'

# Show staged changes diff
alias gd='git diff --cached'

# Commit all tracked changes with message
# @hint <message>
alias gca='git commit -a -m'

# Pull latest changes from remote
alias gp='git pull'

# Pull with rebase (cleaner history)
alias gpl='git pull --rebase'

# Force push safely (with lease)
alias gpf='git push --force-with-lease'

# List branches
alias gb='git branch'

# Checkout branch
alias gco='git checkout'

# Add specific files to staging area
alias ga='git add'

# Add *all* modified and new files to staging area
alias gaa='git add -A'

# Git fetch && git pull
alias gfu='git fetch && git pull'

# ===================================== EOF ====================================
