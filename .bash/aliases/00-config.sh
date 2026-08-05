###############################################################################
# 00-config.sh — Alias group registry helpers
#
# Purpose:
#   Derive alias groups from 20-99 *.sh files (one file = one group). Each
#   group file may declare optional header tags (# @group:, # @keys:) and
#   per-alias hints (# @hint). This file builds parallel-array registries and
#   provides lookup helpers — no GROUP_* membership lists or aliases here.
#
# How this fits in:
#   - Loaded by ~/.bash_aliases (or your loader) before functions and aliases.
#   - Call build_alias_group_registry <aliases-dir> after sourcing group files
#     or before listing/classifying (loader wiring is handled elsewhere).
#   - list_aliases_wrapper (10-functions.sh) uses:
#       • ALIAS_GROUP_ORDER, ALIAS_GROUP_KEYS, ALIAS_GROUP_MEMBERS, ALIAS_GROUP_FILES
#       • group_keys(), group_members(), resolve_group_name(), classify_group()
#       • alias_hint_for()
#
# Conventions:
#   - Group files: NN-<slug>.sh where NN is 20-99 (sorted lexicographically).
#   - Default display name / keys derive from the filename slug.
#   - Header tags at the top of a file override defaults.
###############################################################################

# Globals populated by build_alias_group_registry
ALIAS_GROUP_ORDER=()
ALIAS_GROUP_KEYS=()
ALIAS_GROUP_MEMBERS=()
ALIAS_GROUP_FILES=()
ALIAS_HINT_LINES=""

# Set by alias_group_parse_header
_ag_header_group=""
_ag_header_keys=""

# -----------------------------------------------------------------------------
# _alias_group_slug_from_filename — Strip prefix/suffix from a group filename.
# -----------------------------------------------------------------------------
_alias_group_slug_from_filename()
{
    local filename="$1" base
    base="${filename%.sh}"
    case "$base" in
        [0-9][0-9]-*) base="${base#??-}" ;;
    esac
    case "$base" in
        *-aliases) base="${base%-aliases}" ;;
    esac
    printf '%s\n' "$base"
}

# -----------------------------------------------------------------------------
# _alias_group_titlecase_slug — Hyphenated slug → title-cased words.
# -----------------------------------------------------------------------------
_alias_group_titlecase_slug()
{
    local slug="$1" word first rest result="" old_ifs="$IFS"
    IFS='-'
    set -- $slug
    IFS="$old_ifs"
    for word; do
        [ -n "$word" ] || continue
        first=$(printf '%s' "${word:0:1}" | tr '[:lower:]' '[:upper:]')
        rest=$(printf '%s' "${word:1}" | tr '[:upper:]' '[:lower:]')
        result="${result:+$result }${first}${rest}"
    done
    printf '%s\n' "$result"
}

# -----------------------------------------------------------------------------
# alias_group_default_name — Display name from filename.
# -----------------------------------------------------------------------------
alias_group_default_name()
{
    local slug
    slug="$(_alias_group_slug_from_filename "$1")"
    _alias_group_titlecase_slug "$slug"
}

# -----------------------------------------------------------------------------
# alias_group_default_keys — Comma-separated default key from filename slug.
# -----------------------------------------------------------------------------
alias_group_default_keys()
{
    local slug
    slug="$(_alias_group_slug_from_filename "$1")"
    printf '%s\n' "$(printf '%s' "$slug" | tr '[:upper:]' '[:lower:]')"
}

# -----------------------------------------------------------------------------
# alias_group_parse_header — Read # @group: / # @keys: from file top.
# Sets globals _ag_header_group, _ag_header_keys (empty if unset).
# -----------------------------------------------------------------------------
alias_group_parse_header()
{
    local file="$1" line rest
    local comment_re='^[[:space:]]*#(.*)$'
    _ag_header_group=""
    _ag_header_keys=""
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "${line//[[:space:]]/}" ] && continue
        if [[ "$line" =~ $comment_re ]]; then
            rest="${BASH_REMATCH[1]}"
        else
            break
        fi
        rest="${rest#"${rest%%[![:space:]]*}"}"
        case "$rest" in
            @group:*)
                rest="${rest#@group:}"
                rest="${rest#"${rest%%[![:space:]]*}"}"
                rest="${rest%"${rest##*[![:space:]]}"}"
                _ag_header_group="$rest"
                ;;
            @keys:*)
                rest="${rest#@keys:}"
                rest="${rest#"${rest%%[![:space:]]*}"}"
                rest="${rest%"${rest##*[![:space:]]}"}"
                _ag_header_keys="$rest"
                ;;
        esac
    done < "$file"
}

# -----------------------------------------------------------------------------
# alias_group_parse_members — Space-separated alias names from a group file.
# -----------------------------------------------------------------------------
alias_group_parse_members()
{
    local file="$1" line name result=""
    local alias_re='^[[:space:]]*alias[[:space:]]+([A-Za-z0-9_-]+)='
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ $alias_re ]]; then
            name="${BASH_REMATCH[1]}"
            result="${result:+$result }$name"
        fi
    done < "$file"
    printf '%s\n' "$result"
}

# -----------------------------------------------------------------------------
# alias_group_parse_hints — Lines of name<TAB>hint from # @hint + alias pairs.
# -----------------------------------------------------------------------------
alias_group_parse_hints()
{
    local file="$1" line hint="" name out="" rest
    local comment_re='^[[:space:]]*#(.*)$'
    local alias_re='^[[:space:]]*alias[[:space:]]+([A-Za-z0-9_-]+)='
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ $comment_re ]]; then
            rest="${BASH_REMATCH[1]}"
            rest="${rest#"${rest%%[![:space:]]*}"}"
            case "$rest" in
                @hint|@hint[[:space:]]*)
                    hint="${rest#@hint}"
                    hint="${hint#"${hint%%[![:space:]]*}"}"
                    hint="${hint%"${hint##*[![:space:]]}"}"
                    ;;
            esac
        elif [[ "$line" =~ $alias_re ]]; then
            name="${BASH_REMATCH[1]}"
            if [ -n "$hint" ]; then
                out="${out}${out:+$'\n'}$name$(printf '\t')$hint"
                hint=""
            fi
        fi
    done < "$file"
    printf '%s\n' "$out"
}

# -----------------------------------------------------------------------------
# build_alias_group_registry — Scan a directory of 20-99 group files.
# -----------------------------------------------------------------------------
build_alias_group_registry()
{
    local dir="$1" f base name keys members
    ALIAS_GROUP_ORDER=()
    ALIAS_GROUP_KEYS=()
    ALIAS_GROUP_MEMBERS=()
    ALIAS_GROUP_FILES=()
    ALIAS_HINT_LINES=""

    for f in "$dir"/*.sh; do
        [ -r "$f" ] || continue
        base="$(basename "$f")"
        case "$base" in
            [2-9][0-9]-*.sh) ;;
            *) continue ;;
        esac

        _ag_header_group=""
        _ag_header_keys=""
        alias_group_parse_header "$f"
        name="${_ag_header_group:-$(alias_group_default_name "$base")}"
        keys="${_ag_header_keys:-$(alias_group_default_keys "$base")}"
        members="$(alias_group_parse_members "$f")"

        ALIAS_GROUP_ORDER+=("$name")
        ALIAS_GROUP_KEYS+=("$keys")
        ALIAS_GROUP_MEMBERS+=("$members")
        ALIAS_GROUP_FILES+=("$f")

        local hint_lines
        hint_lines="$(alias_group_parse_hints "$f")"
        if [ -n "$hint_lines" ]; then
            ALIAS_HINT_LINES="${ALIAS_HINT_LINES}${ALIAS_HINT_LINES:+$'\n'}${hint_lines}"
        fi
    done
}

# -----------------------------------------------------------------------------
# group_keys — Comma-separated filter tokens for a canonical group name.
# -----------------------------------------------------------------------------
group_keys()
{
    local i
    for i in "${!ALIAS_GROUP_ORDER[@]}"; do
        if [ "${ALIAS_GROUP_ORDER[$i]}" = "$1" ]; then
            printf '%s\n' "${ALIAS_GROUP_KEYS[$i]}"
            return 0
        fi
    done
}

# -----------------------------------------------------------------------------
# group_members — Space-separated alias names for a canonical group name.
# -----------------------------------------------------------------------------
group_members()
{
    local i
    for i in "${!ALIAS_GROUP_ORDER[@]}"; do
        if [ "${ALIAS_GROUP_ORDER[$i]}" = "$1" ]; then
            printf '%s\n' "${ALIAS_GROUP_MEMBERS[$i]}"
            return 0
        fi
    done
}

# -----------------------------------------------------------------------------
# resolve_group_name — Map a user token to a canonical group name.
# -----------------------------------------------------------------------------
resolve_group_name()
{
    local token lowered g k i
    token="$1"
    lowered=$(printf '%s' "$token" | tr '[:upper:]' '[:lower:]')
    for i in "${!ALIAS_GROUP_ORDER[@]}"; do
        g="${ALIAS_GROUP_ORDER[$i]}"
        IFS=, read -r -a keys <<<"${ALIAS_GROUP_KEYS[$i]}"
        for k in "${keys[@]}"; do
            k=$(printf '%s' "$k" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [ "$lowered" = "$k" ]; then
                printf '%s\n' "$g"
                return 0
            fi
        done
    done
    return 1
}

# -----------------------------------------------------------------------------
# classify_group — Return the group containing an alias, or empty if unknown.
# -----------------------------------------------------------------------------
classify_group()
{
    local name="$1" i members
    for i in "${!ALIAS_GROUP_ORDER[@]}"; do
        members="${ALIAS_GROUP_MEMBERS[$i]}"
        case " $members " in
            *" $name "*) printf '%s\n' "${ALIAS_GROUP_ORDER[$i]}"; return 0 ;;
        esac
    done
    printf '\n'
    return 1
}

# -----------------------------------------------------------------------------
# alias_hint_for — Hint text for an alias, or empty if none.
# -----------------------------------------------------------------------------
alias_hint_for()
{
    local name="$1" line
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        case "$line" in
            "$name"$'\t'*) printf '%s\n' "${line#*$'\t'}"; return 0 ;;
        esac
    done <<EOF
$ALIAS_HINT_LINES
EOF
}

# ===================================== EOF ====================================
