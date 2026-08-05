#!/usr/bin/env bash
set -euo pipefail

TEST_ROOT="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$TEST_ROOT/.." && pwd)"
FAIL=0

# shellcheck source=/dev/null
. "$REPO_ROOT/.bash/aliases/00-config.sh"
# shellcheck source=/dev/null
. "$TEST_ROOT/test_registry.sh"
# shellcheck source=/dev/null
. "$TEST_ROOT/test_alias_mgmt.sh"

test_default_name_from_filename
test_default_keys_from_filename
test_header_overrides
test_indented_directives
test_header_rejects_inline_directives
test_hints_reject_inline_directives
test_hints_reject_false_prefix_matches
test_parse_members_and_hints
test_build_registry
test_alias_quote_and_format
test_alias_next_group_nn
test_alias_file_roundtrip

if [ "$FAIL" -ne 0 ]; then
    echo "FAILED"
    exit 1
fi
echo "ALL PASSED"
