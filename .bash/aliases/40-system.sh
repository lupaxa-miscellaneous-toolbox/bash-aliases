# shellcheck shell=bash
###############################################################################
# 40-system.sh — System / machine helpers
#
# Homebrew bundle sync and local print shortcuts.
###############################################################################

# @group: System
# @keys: system,sys,brew,homebrew,print

# -----------------------------------------------------------------------------
# Printing
# -----------------------------------------------------------------------------
alias print='lpr -o sides=two-sided-long-edge -o prettyprint'

# Numbered pretty-print via my_print() in 10-functions.sh
alias lprint='my_print'

# -----------------------------------------------------------------------------
# Homebrew
# -----------------------------------------------------------------------------
alias export-brew='brew bundle dump --describe --file=~/Desktop/GitMaster/Lupraxus/config-files/Brewfile --force'
alias import-brew='brew bundle --file=~/Desktop/GitMaster/Lupraxus/config-files/Brewfile'

# ===================================== EOF ====================================
