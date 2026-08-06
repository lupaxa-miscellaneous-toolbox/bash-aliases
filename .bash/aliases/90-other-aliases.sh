# shellcheck shell=bash
###############################################################################
# 90-other-aliases.sh — Other
# Small catch-all shortcuts that do not need their own group file.
###############################################################################

# @group: Other
# @keys: other,misc,miscellaneous

alias la='ls -A'
alias ll='ls -lah'
mkcd() { mkdir -p -- "$1" && cd -- "$1" || return; }
alias rmf='rm -i'
alias myip='curl -fsS https://ifconfig.me'

# ===================================== EOF ====================================
