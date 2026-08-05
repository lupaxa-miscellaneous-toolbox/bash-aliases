# shellcheck shell=bash
###############################################################################
# ~/.bash_aliases (loader)
# Dynamically loads all alias-related scripts from ~/.bash/aliases/
# Files are sourced in lexicographic (alphabetical) order.
# Use numeric prefixes (e.g., 00-, 10-, 20-) to control load order.
# Groups are derived from 20-*.sh … 99-*.sh (see 00-config.sh).
###############################################################################

# Override for tests / alternate installs: BASH_ALIAS_DIR=/path/to/aliases
BASH_ALIAS_DIR="${BASH_ALIAS_DIR:-$HOME/.bash/aliases}"
alias_dir="$BASH_ALIAS_DIR"

if [ -d "$alias_dir" ]; then
    for f in "$alias_dir"/*.sh; do
        # Dynamic path from alias_dir — cannot be a constant source.
        # shellcheck disable=SC1090
        [ -r "$f" ] && . "$f"
    done
    # Build file→group registry after helpers (00) and group files are present
    if declare -F build_alias_group_registry >/dev/null 2>&1; then
        build_alias_group_registry "$alias_dir"
    fi
else
    echo "⚠️  Alias directory not found: $alias_dir"
fi

alias reload-aliases='source ~/.bash_aliases && echo "🔁 Aliases reloaded."'
