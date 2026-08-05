###############################################################################
# 20-other-aliases.sh — Miscellaneous / General-purpose aliases
#
# Purpose:
#   This file is reserved for all aliases that don't neatly fit into other
#   groups (e.g., Alias management or Git). It's a good place to define
#   simple quality-of-life shell shortcuts, system helpers, or navigation
#   commands that improve your daily workflow.
#
#   Typical examples might include:
#     • Enhanced 'ls' variants (e.g., `ll`, `la`)
#     • Directory helpers (e.g., `mkcd`)
#     • System shortcuts or diagnostic commands
#
# Structure:
#   - Keep function-based helpers minimal here; store logic-heavy ones in a
#     dedicated functions file instead.
#   - Aliases defined in this file are grouped under “Other” via the header
#     tags below (no manual registration in 00-config.sh).
#
# Example workflow:
#   list-aliases other       # Display only “Other” group aliases
#   reload-aliases           # Reload after adding new shortcuts
#
# Notes:
#   - All aliases in this file are optional and safe to comment out.
#   - You can split this further (e.g., 29-system-aliases.sh, 29-docker.sh)
#     if you have many miscellaneous aliases.
###############################################################################

# @group: Other
# @keys: other,misc,miscellaneous

alias print='lpr -o sides=two-sided-long-edge -o prettyprint'

alias lprint='my_print'

alias export-brew='brew bundle dump --describe --file=~/Desktop/GitMaster/Lupraxus/config-files/Brewfile --force'
alias import-brew='brew bundle --file=~/Desktop/GitMaster/Lupraxus/config-files/Brewfile'

alias mkdocs-tailnet='mkdocs serve --dev-addr "$(tailscale ip -4):8000"'

###############################################################################
# Example aliases — Uncomment or modify as needed
###############################################################################

# Directory listings
# alias la='ls -A'           # List all files except . and ..
# alias ll='ls -lah'         # Long format with human-readable sizes

# Directory creation + navigation
# mkcd() { mkdir -p -- "$1" && cd -- "$1"; }  # Make dir and enter it

# Quick system info
# alias dfh='df -h'          # Human-readable disk usage
# alias duh='du -h --max-depth=1' # Summarize folder sizes

# Networking
# alias myip='curl -s ifconfig.me'  # Get external IP address

# File management
# alias rmf='rm -i'          # Interactive file removal (safety prompt)

###############################################################################
# To add new aliases to this group:
#   1) Define them in this file.
#   2) Run `reload-aliases`.
#
# To add a new group:
#   1) Create ~/.bash/aliases/NN-name.sh (NN >= 20), optional header:
#        # @group: Display Name
#        # @keys: key1,key2
#   2) Add alias lines in that file.
#   3) Run `reload-aliases`.
###############################################################################
