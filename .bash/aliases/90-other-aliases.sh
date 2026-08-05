# shellcheck shell=bash
###############################################################################
# 90-other-aliases.sh — Miscellaneous / catch-all
#
# Aliases that do not belong in a dedicated group (System, MkDocs, Git, …).
# Prefer creating a new NN-group.sh file when a theme grows beyond one-offs.
###############################################################################

# @group: Other
# @keys: other,misc,miscellaneous

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
