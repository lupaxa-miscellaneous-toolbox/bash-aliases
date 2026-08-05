# shellcheck shell=bash
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
#   • Group configuration is registry-backed from 00-config.sh / file scan.
#   • Function definitions avoid the 'function' keyword; opening brace on next line.
#
# Dependencies:
#   • Requires the following from 00-config.sh:
#       - ALIAS_GROUP_ORDER (Bash array; preserves names with spaces)
#       - ALIAS_GROUP_FILES / ALIAS_GROUP_MEMBERS
#       - group_keys()
#       - group_members()
#       - resolve_group_name()
#       - classify_group()
#       - alias_hint_for()
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

    local printed_any=0

    # Iterate over canonical groups in configured order
    for group in "${ALIAS_GROUP_ORDER[@]}"; do
        # Apply optional group filter
        if [ -n "$filter_group" ] && [ "$group" != "$filter_group" ]; then
            continue
        fi

        # Group header
        printf "%-40s-+-%s\n" "$rule_left" "$rule_right"
        printf "%-40s | %s\n" "Alias group: $group" "Alias command"
        printf "%-40s-+-%s\n" "$rule_left" "$rule_right"

        # Walk each alias (name=cmd) and render those that belong to this group
        while IFS='=' read -r name cmd; do
            # Skip self to avoid recursive/awkward display
            case "$name" in
                list_aliases_wrapper|list-aliases) continue ;;
            esac

            # Determine alias' group
            local g
            if ! g="$(classify_group "$name")"; then
                continue
            fi
            [ "$g" != "$group" ] && continue

            # Parameter hints from the group registry
            local display="$name" hint
            hint="$(alias_hint_for "$name")"
            if [ -n "$hint" ]; then
                display="$name $hint"
            fi

            printf "%-40s | %s\n" "$display" "$cmd"
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
# _alias_mgmt_define — Define an alias in the current session from name + cmd.
###############################################################################
_alias_mgmt_define()
{
    local name="$1" cmd="$2"
    eval "alias ${name}=$(printf '%q' "$cmd")"
}

###############################################################################
# _alias_mgmt_refresh_registry — Rebuild registry from BASH_ALIAS_DIR.
###############################################################################
_alias_mgmt_refresh_registry()
{
    build_alias_group_registry "$(bash_alias_dir)"
}

###############################################################################
# add_alias_wrapper — Append an alias to a group file (create group if needed)
#
# Usage:
#   add-alias <group> <name> <command...>
#
# Behavior:
#   • <group> may be an existing filter token (git, system, …) or a new slug.
#   • New groups create NN-slug.sh under the aliases directory.
#   • Defines the alias in the current session and rebuilds the registry.
###############################################################################
add_alias_wrapper()
{
    if [ $# -lt 3 ]; then
        echo "❌ Usage: add-alias <group> <name> <command...>"
        return 1
    fi

    local group_token="$1" name="$2"
    shift 2
    local cmd="$*"
    local dir canonical file

    dir="$(bash_alias_dir)"
    if [ ! -d "$dir" ]; then
        echo "❌ Alias directory not found: $dir"
        return 1
    fi

    case "$name" in
        *[!A-Za-z0-9_-]*|"")
            echo "❌ Invalid alias name: $name"
            return 1
            ;;
    esac

    if alias "$name" >/dev/null 2>&1 || alias_group_file_for_name "$name" >/dev/null 2>&1; then
        echo "❌ Alias '$name' already exists. Use edit-alias to change it."
        return 1
    fi

    if canonical="$(resolve_group_name "$group_token" 2>/dev/null)"; then
        file="$(alias_group_file_for_canonical "$canonical")" || {
            echo "❌ Resolved group '$canonical' but no file is registered."
            return 1
        }
    else
        echo "📁 Creating new group from slug '$group_token'..."
        file="$(alias_create_group_file "$dir" "$group_token")" || return 1
        echo "   → $file"
    fi

    alias_append_to_file "$file" "$name" "$cmd" || return 1
    _alias_mgmt_define "$name" "$cmd"
    _alias_mgmt_refresh_registry

    echo "✅ Added alias $name → $cmd"
    echo "   Group file: $file"
}

###############################################################################
# edit_alias_wrapper — Change an alias command in its group file
#
# Usage:
#   edit-alias <name> <new command...>
#   edit-alias <name>                 # prompts for the new command
###############################################################################
edit_alias_wrapper()
{
    if [ $# -lt 1 ]; then
        echo "❌ Usage: edit-alias <name> <new command...>"
        return 1
    fi

    local name="$1"
    shift
    local cmd="$*" file

    if ! file="$(alias_group_file_for_name "$name")"; then
        echo "⚠️  Alias '$name' is not in any group file."
        return 1
    fi

    if [ -z "$cmd" ]; then
        if alias "$name" >/dev/null 2>&1; then
            echo "Current: $(alias "$name")"
        fi
        read -rp "New command for '$name': " cmd
        echo
        if [ -z "$cmd" ]; then
            echo "🚫 Empty command — cancelled."
            return 1
        fi
    fi

    if ! alias_replace_in_file "$file" "$name" "$cmd"; then
        echo "❌ Could not update alias '$name' in $file"
        return 1
    fi

    _alias_mgmt_define "$name" "$cmd"
    _alias_mgmt_refresh_registry

    echo "✅ Updated alias $name → $cmd"
    echo "   Group file: $file"
}

###############################################################################
# delete_alias_wrapper — Delete an alias (session and/or group file)
#
# Usage:
#   delete-alias <name>
#   delete-alias <name> --session
#   delete-alias <name> --file
#
# Behavior:
#   • --session: unalias for this shell only
#   • --file: remove from the group file (and unalias if defined)
#   • no flag: interactive choice
###############################################################################
delete_alias_wrapper()
{
    if [ $# -lt 1 ]; then
        echo "❌ Usage: delete-alias <name> [--session|--file]"
        return 1
    fi

    local name="$1" mode="" file=""
    shift || true

    while [ $# -gt 0 ]; do
        case "$1" in
            --session|-s) mode="session" ;;
            --file|-f)    mode="file" ;;
            *)
                echo "❌ Unknown option: $1"
                echo "   Usage: delete-alias <name> [--session|--file]"
                return 1
                ;;
        esac
        shift
    done

    file="$(alias_group_file_for_name "$name" 2>/dev/null)" || file=""

    if ! alias "$name" >/dev/null 2>&1 && [ -z "$file" ]; then
        echo "⚠️  Alias '$name' does not exist in this session or any group file."
        return 1
    fi

    if alias "$name" >/dev/null 2>&1; then
        echo "🗑️  Session: $(alias "$name")"
    fi
    if [ -n "$file" ]; then
        echo "📄 File:    $file"
    fi

    if [ -z "$mode" ]; then
        echo
        echo "Delete '$name' how?"
        echo "  s) session only"
        if [ -n "$file" ]; then
            echo "  f) remove from group file (permanent)"
        fi
        echo "  n) cancel"
        read -rp "Choice [s/f/n]: " ans
        echo
        case "$ans" in
            [Ss]) mode="session" ;;
            [Ff])
                if [ -z "$file" ]; then
                    echo "⚠️  No group file for '$name'; session-only delete."
                    mode="session"
                else
                    mode="file"
                fi
                ;;
            *)
                echo "🚫 Deletion cancelled."
                return 1
                ;;
        esac
    fi

    if [ "$mode" = "file" ]; then
        if [ -z "$file" ]; then
            echo "❌ Alias '$name' is not stored in a group file."
            return 1
        fi
        if ! alias_remove_from_file "$file" "$name"; then
            echo "❌ Failed to remove '$name' from $file"
            return 1
        fi
        unalias "$name" 2>/dev/null || true
        _alias_mgmt_refresh_registry
        echo "✅ Alias '$name' removed from $file (and this session)."
        return 0
    fi

    # session
    if ! alias "$name" >/dev/null 2>&1; then
        echo "⚠️  Alias '$name' is not defined in this session."
        return 1
    fi
    if unalias "$name"; then
        echo "✅ Alias '$name' deleted for this session (group file unchanged)."
    else
        echo "❌ Failed to delete alias '$name'."
        return 1
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
    local ok=1 i name members f
    echo "🔎 Checking alias groups (file → group registry)..."

    if [ "${#ALIAS_GROUP_ORDER[@]}" -eq 0 ]; then
        echo "⚠️  No groups registered. Did build_alias_group_registry run?"
        return 1
    fi

    for i in "${!ALIAS_GROUP_ORDER[@]}"; do
        f="${ALIAS_GROUP_FILES[$i]}"
        if [ ! -r "$f" ]; then
            echo "⚠️  Group '${ALIAS_GROUP_ORDER[$i]}': file not readable: $f"
            ok=0
            continue
        fi
        members="${ALIAS_GROUP_MEMBERS[$i]}"
        for name in $members; do
            if ! alias "$name" >/dev/null 2>&1; then
                echo "⚠️  In group '${ALIAS_GROUP_ORDER[$i]}': alias '$name' not found (typo or not loaded yet?)"
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
