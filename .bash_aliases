###############################################################################
# ~/.bash_aliases (loader)
# Dynamically loads all alias-related scripts from ~/.bash/aliases/
# Files are sourced in lexicographic (alphabetical) order.
# Use numeric prefixes (e.g., 00-, 10-, 20-) to control load order.
###############################################################################

alias_dir="$HOME/.bash/aliases"

# Only proceed if the directory exists
if [ -d "$alias_dir" ]; then
    for f in "$alias_dir"/*.sh; do
        [ -r "$f" ] && . "$f"
    done
else
    echo "⚠️  Alias directory not found: $alias_dir"
fi

# Quick reload of all alias files
alias reload-aliases='source ~/.bash_aliases && echo "🔁 Aliases reloaded."'
