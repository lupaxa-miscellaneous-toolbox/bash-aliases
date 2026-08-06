# shellcheck shell=bash
###############################################################################
# 40-system.sh — System
# Disk/PATH helpers and optional Homebrew Bundle shortcuts.
###############################################################################

# @group: System
# @keys: system,sys,brew,homebrew

# Override in ~/.bashrc if your Brewfile lives elsewhere.
: "${BREWFILE:=$HOME/Brewfile}"

alias dfh='df -h'
alias path='echo "$PATH" | tr ":" "\n"'

alias brew-outdated='brew outdated'
alias brew-update='brew update && brew upgrade'
alias export-brew='brew bundle dump --describe --file="$BREWFILE" --force'
alias import-brew='brew bundle --file="$BREWFILE"'

# ===================================== EOF ====================================
