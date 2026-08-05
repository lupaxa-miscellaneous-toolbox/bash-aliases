###############################################################################
# 20-alias-management.sh — Public alias management commands
#
# Purpose:
#   This file defines the *public*, user-facing aliases that expose the
#   management and diagnostic functions implemented in `10-functions.sh`.
#
#   These commands allow you to:
#     • List all loaded aliases in a readable, grouped table.
#     • Show available alias groups and their filter tokens.
#     • Delete an alias interactively for the current session.
#     • Verify that your configured groups (in 00-config.sh) reference valid aliases.
#
# Conventions:
#   - Wrapper functions have underscored names (POSIX-compatible).
#   - Public aliases use hyphenated names for readability and discoverability.
#   - This file should be sourced *after* 00-config.sh and 10-functions.sh.
#
# Related files:
#   • 00-config.sh      — Defines alias groups and classification helpers.
#   • 10-functions.sh   — Contains the backing implementations of these commands.
#
# Usage examples:
#   list-aliases                 # Show all aliases grouped by category
#   list-aliases git             # Show only Git-related aliases
#   list-alias-groups            # Display available groups
#   delete-alias list-aliases    # Remove a specific alias for this session
#   check-alias-groups           # Validate group-to-alias consistency
###############################################################################

# -----------------------------------------------------------------------------
# list-aliases — Display all loaded aliases in a structured table
# Wrapper: list_aliases_wrapper()
# Description:
#   Lists all active aliases grouped by category (Alias management, Git, etc.)
#   Uses group definitions and classifications from 00-config.sh.
# -----------------------------------------------------------------------------
alias list-aliases='list_aliases_wrapper'

# -----------------------------------------------------------------------------
# list-alias-groups — Show all defined alias groups and their filter tokens
# Wrapper: list_alias_groups_wrapper()
# Description:
#   Prints a list of canonical groups along with the keywords you can use to
#   filter them in `list-aliases`. Helpful for remembering filter keys.
# -----------------------------------------------------------------------------
alias list-alias-groups='list_alias_groups_wrapper'

# -----------------------------------------------------------------------------
# delete-alias — Delete an alias for the current shell session
# Wrapper: delete_alias_wrapper()
# Description:
#   Interactively deletes a named alias (temporary). The user is prompted for
#   confirmation before the alias is removed.
# -----------------------------------------------------------------------------
alias delete-alias='delete_alias_wrapper'

# -----------------------------------------------------------------------------
# check-alias-groups — Validate that all configured group members exist
# Wrapper: check_alias_groups_wrapper()
# Description:
#   Cross-checks group membership lists from 00-config.sh against the aliases
#   actually loaded into the current session. Warns if any are missing or
#   misnamed.
# -----------------------------------------------------------------------------
alias check-alias-groups='check_alias_groups_wrapper'

# ===================================== EOF ====================================
