# shellcheck shell=bash
###############################################################################
# 50-mkdocs.sh — MkDocs helpers
#
# Serve docs on the Tailscale IPv4 address for LAN/tailnet access.
###############################################################################

# @group: MkDocs
# @keys: mkdocs,docs

alias mkdocs-tailnet='mkdocs serve --dev-addr "$(tailscale ip -4):8000"'

# ===================================== EOF ====================================
