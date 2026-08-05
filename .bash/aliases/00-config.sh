###############################################################################
# 00-config.sh — Alias Group Configuration & Helpers
#
# Purpose:
#   Centralize alias grouping and lookup logic for your modular alias system.
#   - Define which aliases belong to which groups (e.g., “Git”, “Alias management”).
#   - Provide helper functions that:
#       • map user-friendly group filter tokens to canonical group names,
#       • return the members of a given group,
#       • classify an alias into a group (with “Other” as the default fallback).
#
# How this fits in:
#   - Loaded by ~/.bash_aliases (or your loader) *before* functions and public aliases.
#   - list_aliases_wrapper (in 10-functions.sh) relies on:
#       • ALIAS_GROUP_ORDER
#       • group_keys()
#       • group_members()
#       • resolve_group_name()
#       • classify_group()
#
# Conventions:
#   - Public, hyphenated commands (e.g., `list-aliases`) are defined in 20-*.sh files.
#   - This file only provides configuration and small utilities—no aliases here.
#   - Group names can contain spaces. Order is controlled by ALIAS_GROUP_ORDER (Bash array).
#
# Notes:
#   - “Other” is the fallback group for any alias not explicitly listed in a group.
#   - When adding groups:
#       1) Add a GROUP_<NAME> variable listing its alias names (space-separated).
#       2) Add the canonical group name to ALIAS_GROUP_ORDER.
#       3) Teach group_keys() and group_members() about the group.
###############################################################################

# -----------------------------------------------------------------------------
# Group membership lists (space-separated alias names)
#   • Add/remove alias names as needed. Names must match the *public* alias
#     names declared in your 20-*.sh files (e.g., alias gc='git clone').
# -----------------------------------------------------------------------------
GROUP_ALIAS_MANAGEMENT="list-aliases list-alias-groups reload-aliases delete-alias check-alias-groups"
GROUP_GIT="gc gs gl gd gca gp gpl gpf gb gco ga push-all tag-push undo-last-commit gaa gfu"
GROUP_OTHER="la ll mkcd"

# -----------------------------------------------------------------------------
# Display order for groups (array preserves names with spaces)
#   • Controls the order groups appear in list outputs.
#   • Add new canonical group names here when you create them.
# -----------------------------------------------------------------------------
ALIAS_GROUP_ORDER=("Alias management" "Git" "Other")

# -----------------------------------------------------------------------------
# group_keys — Return accepted filter tokens for a canonical group name.
# Usage:
#   group_keys "Git"                 # -> "git"
#   group_keys "Alias management"    # -> "alias,aliases,management"
# Behavior:
#   • Returns a comma-separated, lowercase list of tokens that users can pass
#     to `list-aliases <token>` to filter by this group.
# -----------------------------------------------------------------------------
group_keys()
{
    case "$1" in
        "Alias management") echo "alias,aliases,management" ;;
        "Git")              echo "git" ;;
        "Other")            echo "other,misc,miscellaneous" ;;
    esac
}

# -----------------------------------------------------------------------------
# group_members — Return space-separated alias names for a canonical group.
# Usage:
#   group_members "Git"              # -> "gc gs gl ... undo-last-commit"
# Behavior:
#   • Maps a canonical group name to its configured alias member list.
#   • “Other” returns empty here because it is a *fallback* bucket only.
# -----------------------------------------------------------------------------
group_members()
{
    case "$1" in
        "Alias management") echo "$GROUP_ALIAS_MANAGEMENT" ;;
        "Git")              echo "$GROUP_GIT" ;;
        "Other")            echo "" ;;   # Fallback is computed dynamically
    esac
}

# -----------------------------------------------------------------------------
# resolve_group_name — Map a user token to a canonical group name.
# Usage:
#   resolve_group_name "git"         # -> "Git"
#   resolve_group_name "aliases"     # -> "Alias management"
# Return:
#   0 with canonical group name on stdout if matched; 1 if unknown.
# Behavior:
#   • Case-insensitive match against tokens from group_keys().
#   • Used by list_aliases_wrapper to parse optional filters.
# -----------------------------------------------------------------------------
resolve_group_name()
{
    local token lowered g k
    token="$1"
    lowered=$(printf '%s' "$token" | tr '[:upper:]' '[:lower:]')

    # Iterate ordered list to respect canonical display order
    for g in "${ALIAS_GROUP_ORDER[@]}"; do
        IFS=, read -r -a keys <<<"$(group_keys "$g")"
        for k in "${keys[@]}"; do
            if [ "$lowered" = "$k" ]; then
                printf '%s\n' "$g"
                return 0
            fi
        done
    done
    return 1
}

# -----------------------------------------------------------------------------
# classify_group — Determine which canonical group an alias belongs to.
# Usage:
#   classify_group "gc"              # -> "Git"
# Behavior:
#   • Checks each explicit group’s members in ALIAS_GROUP_ORDER (skipping “Other”).
#   • If no membership matches, returns “Other”.
# Notes:
#   • Matching is string-exact against configured alias names.
#   • Keep GROUP_* lists in sync with your public aliases to avoid surprises.
# -----------------------------------------------------------------------------
classify_group()
{
    local name="$1" g members

    # Try all explicit groups in order (skip fallback “Other” during checks)
    for g in "${ALIAS_GROUP_ORDER[@]}"; do
        [ "$g" = "Other" ] && continue
        members="$(group_members "$g")"

        # Word-boundary style match using space-padding to avoid partial hits
        case " $members " in
            *" $name "*) printf '%s\n' "$g"; return 0 ;;
        esac
    done

    # Default fallback
    printf 'Other\n'
}

# ===================================== EOF ====================================
