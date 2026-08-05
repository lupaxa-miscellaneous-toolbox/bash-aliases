###############################################################################
# 10-functions.sh — Functions used by the alias system
#
# Purpose:
#   Provide reusable Bash functions (underscored names) for:
#     • Listing aliases in grouped tables with an optional group filter.
#     • Displaying available groups.
#     • Deleting an alias safely for the current session.
#     • Helpful Git wrappers (undo last commit, push-all, tag-push).
#     • Sanity check to ensure configured groups reference real aliases.
#
# Conventions:
#   • Public hyphenated commands are defined as aliases in 20-*.sh files
#     (e.g., alias list-aliases='list_aliases_wrapper').
#   • Group configuration lives in 00-config.sh and must be sourced first.
#   • Function definitions avoid the 'function' keyword; opening brace on next line.
#
# Dependencies:
#   • Requires the following from 00-config.sh:
#       - ALIAS_GROUP_ORDER (Bash array; preserves names with spaces)
#       - group_keys()
#       - group_members()
#       - resolve_group_name()
#       - classify_group()
#
# Notes:
#   • Output formatting uses fixed-width columns for consistent table rendering.
#   • Known parameterized aliases get display hints (e.g., 'push-all <message>').
###############################################################################

###############################################################################
# list_aliases_wrapper — Pretty list of aliases (grouped), optional group filter
#
# Usage:
#   list-aliases            # show all groups
#   list-aliases git        # filter to group by token (case-insensitive)
#   list-aliases alias      # filter to "Alias management"
#   list-aliases other      # filter to "Other"
#
# Behavior:
#   • Reads all current aliases via `alias -p`.
#   • Classifies each alias into a group via classify_group().
#   • Optionally filters by a user token (resolved by resolve_group_name()).
#   • Adds parameter hints for known parameterized aliases.
#   • Prints a 2-column table per group with clean separators.
###############################################################################
list_aliases_wrapper()
{
    local filter_group=""
    if [ $# -ge 1 ]; then
        # Map user token (e.g., "git") to canonical group name ("Git")
        if ! filter_group="$(resolve_group_name "$1")"; then
            echo "❌ Unknown group '$1'"
            list_alias_groups_wrapper
            return 1
        fi
    fi

    # Collect aliases as sorted "name=cmd" lines
    local lines
    # Only match single-line aliases of the form: alias name='value'
    lines="$(alias -p | sed -nE "s/^alias ([^=]+)='([^']*)'$/\1=\2/p" | sort)"

    # Table formatting
    echo
    local rule_left="----------------------------------------"
    local rule_right="------------------------------------------------------------"
    local fmt="%-40s | %s\n"

    local printed_any=0

    # Iterate over canonical groups in configured order
    for group in "${ALIAS_GROUP_ORDER[@]}"; do
        # Apply optional group filter
        if [ -n "$filter_group" ] && [ "$group" != "$filter_group" ]; then
            continue
        fi

        # Group header
        printf "%-40s-+-%s\n" "$rule_left" "$rule_right"
        printf "$fmt" "Alias group: $group" "Alias command"
        printf "%-40s-+-%s\n" "$rule_left" "$rule_right"

        local group_printed=0

        # Walk each alias (name=cmd) and render those that belong to this group
        while IFS='=' read -r name cmd; do
            # Skip self to avoid recursive/awkward display
            case "$name" in
                list_aliases_wrapper|list-aliases) continue ;;
            esac

            # Determine alias' group
            local g
            g="$(classify_group "$name")"
            [ "$g" != "$group" ] && continue

            # Parameter hints for known parameterized aliases
            local display="$name"
            case "$name" in
                push-all)          display="$name <message>" ;;
                delete-alias)      display="$name <alias_name>" ;;
                tag-push)          display="$name <tag> [message]" ;;
                gca)               display="$name <message>" ;;
            esac

            printf "$fmt" "$display" "$cmd"
            group_printed=1
            printed_any=1
        done <<EOF
$lines
EOF

        # Group footer separator
        printf "%-40s-+-%s\n" "$rule_left" "$rule_right"
        echo
    done

    # If a filter was supplied but nothing matched, tell the user
    if [ -n "$filter_group" ] && [ $printed_any -eq 0 ]; then
        echo "ℹ️  No aliases found for group: $filter_group"
    fi
}

###############################################################################
# list_alias_groups_wrapper — List available groups and their filter tokens
#
# Usage:
#   list-alias-groups
#
# Behavior:
#   • Prints each canonical group from ALIAS_GROUP_ORDER.
#   • Shows accepted tokens (from group_keys) that resolve to each group.
#   • Provides brief usage examples for filtering.
###############################################################################
list_alias_groups_wrapper()
{
    echo
    echo "Available alias groups (use with: list-aliases <group>)"
    echo
    local g keys
    for g in "${ALIAS_GROUP_ORDER[@]}"; do
        keys="$(group_keys "$g")"
        printf "  • %-17s (keys: %s)\n" "$g" "$keys"
    done
    echo
    echo "Examples:"
    echo "  list-aliases"
    echo "  list-aliases git"
    echo "  list-aliases alias"
    echo "  list-aliases other"
    echo
}

###############################################################################
# delete_alias_wrapper — Delete an alias by name (current session only)
#
# Usage:
#   delete-alias <alias_name>
#
# Behavior:
#   • Verifies the alias exists, shows its definition, and asks for confirmation.
#   • Removes only from the *current shell session* (unalias).
#   • To remove permanently, delete it from your 20-*.sh files and reload.
###############################################################################
delete_alias_wrapper()
{
    if [ $# -eq 0 ]; then
        echo "❌ Usage: delete-alias <alias_name>"
        return 1
    fi

    local name="$1"

    # Ensure alias exists for this shell
    if ! alias "$name" >/dev/null 2>&1; then
        echo "⚠️  Alias '$name' does not exist."
        return 1
    fi

    echo "🗑️  Found: $(alias "$name")"
    read -rp "Delete alias '$name' for this session? (y/n) " ans
    echo

    if [[ $ans =~ ^[Yy] ]]; then
        if unalias "$name"; then
            echo "✅ Alias '$name' deleted for this session."
        else
            echo "❌ Failed to delete alias '$name'."
            return 1
        fi
    else
        echo "🚫 Deletion cancelled."
    fi
}

###############################################################################
# Git helpers (functions only; public hyphenated aliases in 20-*.sh)
###############################################################################

###############################################################################
# undo_last_commit_wrapper — Undo last commit (keep changes staged)
#
# Usage:
#   undo-last-commit
#
# Behavior:
#   • Performs a soft reset to the previous commit, keeping your changes staged.
#   • Asks for confirmation before modifying history.
#   • Safe pattern when you misworded a commit but want to re-commit immediately.
###############################################################################
undo_last_commit_wrapper()
{
    echo "⚠️  This will undo the last commit but keep changes staged."
    read -rp "Continue? (y/n) " ans
    [[ $ans =~ ^[Yy] ]] || { echo "🚫 Cancelled."; return 1; }

    git reset --soft HEAD~1 && echo "✅ Last commit undone (changes remain staged)."
}

###############################################################################
# push_all_wrapper — Add, commit, and optionally push with confirmation
#
# Usage:
#   push-all <commit message>
#
# Behavior:
#   • Stages all changes, commits with the provided message, and optionally pushes.
#   • Detects current branch name for display.
#   • Skips push unless explicitly confirmed.
#   • Gracefully exits if nothing is staged to commit.
###############################################################################
push_all_wrapper()
{
    if [ $# -eq 0 ]; then
        echo "❌ Usage: push-all <commit message>"
        return 1
    fi

    local msg="$*"
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    echo "🚀 Preparing to commit on branch: ${branch:-unknown}"
    echo "💬 Commit message: '$msg'"
    echo

    # Stage all changes
    git add -A || return 1

    # If nothing staged, bail out early
    if git diff --cached --quiet; then
        echo "ℹ️  No staged changes; nothing to commit."
        return 0
    fi

    # Commit with message
    if ! git commit -m "$msg"; then
        echo "❌ Commit failed."
        return 1
    fi

    echo
    read -rp "⚠️  Push to remote '${branch:-current branch}'? (y/n) " ans
    echo

    if [[ $ans =~ ^[Yy] ]]; then
        echo "📤 Pushing..."
        if ! git push; then
            echo "❌ Push failed."
            return 1
        fi
    else
        echo "🚫 Push cancelled."
    fi
}

###############################################################################
# tag_push_wrapper — Create an annotated tag and push tags
#
# Usage:
#   tag-push <tag> [message]
#
# Behavior:
#   • Creates an *annotated* tag (-a) with the given message (defaults to "Tag <tag>").
#   • Pushes all tags afterwards (`git push --tags`).
#   • Exits non-zero on failure at any step.
###############################################################################
tag_push_wrapper()
{
    if [ $# -lt 1 ]; then
        echo "❌ Usage: tag-push <tag> [message]"
        return 1
    fi

    local tag="$1"
    shift
    local msg="${*:-Tag $tag}"

    echo "🏷️  Creating tag: $tag"
    git tag -a "$tag" -m "$msg" || return 1

    echo "📤 Pushing tags..."
    git push --tags || return 1

    echo "✅ Tag '$tag' created and pushed successfully."
}

###############################################################################
# check_alias_groups_wrapper — Verify group config matches loaded aliases
#
# Usage:
#   check-alias-groups
#
# Behavior:
#   • Iterates over groups in ALIAS_GROUP_ORDER.
#   • For each configured member name, checks a matching alias is currently defined.
#   • Warns for missing aliases (typos or files not yet loaded).
#   • Returns success (0) if all good; non-zero otherwise.
###############################################################################
check_alias_groups_wrapper()
{
    local ok=1 g name members
    echo "🔎 Checking that group members are defined as aliases..."

    # Iterate over the array to preserve group names with spaces
    for g in "${ALIAS_GROUP_ORDER[@]}"; do
        members="$(group_members "$g")"
        for name in $members; do
            if ! alias "$name" >/dev/null 2>&1; then
                echo "⚠️  In group '$g': alias '$name' not found (typo or not loaded yet?)"
                ok=0
            fi
        done
    done

    [ $ok -eq 1 ] && echo "✅ Groups look good."
    return $((!ok))
}

###############################################################################
# my_print — print files to the laster printer
#
# Usage:
#   orint $filename
###############################################################################

my_print()
{
    if [ "$#" -ne 1 ]; then
        echo "print: error: exactly one filename is required" >&2
        echo "usage: print <file>" >&2
        return 2
    fi

    if [ ! -r "$1" ]; then
        echo "print: error: cannot read file: $1" >&2
        return 2
    fi

    title="$(basename "${1}")"

    nl -ba -w4 -s"| " "$1" | lpr -J "${title}" -o sides=two-sided-long-edge -o prettyprint
}

# ===================================== EOF ====================================
