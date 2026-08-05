#!/usr/bin/env bash
# Sourced by run-tests.sh after 00-config.sh

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "  PASS: $desc"
    else
        echo "  FAIL: $desc"
        echo "        expected: [$expected]"
        echo "        actual:   [$actual]"
        FAIL=1
    fi
}

test_default_name_from_filename() {
    echo "test_default_name_from_filename"
    assert_eq "git-aliases → Git" "Git" "$(alias_group_default_name "20-git-aliases.sh")"
    assert_eq "docker → Docker" "Docker" "$(alias_group_default_name "30-docker.sh")"
    assert_eq "alias-management → Alias Management" "Alias Management" "$(alias_group_default_name "25-alias-management.sh")"
}

test_header_overrides() {
    echo "test_header_overrides"
    local f="$TEST_ROOT/fixtures/25-alias-management.sh"
    _ag_header_group=""
    _ag_header_keys=""
    alias_group_parse_header "$f"
    assert_eq "header group" "Alias management" "$_ag_header_group"
    assert_eq "header keys" "alias,aliases,management" "$_ag_header_keys"
}

test_parse_members_and_hints() {
    echo "test_parse_members_and_hints"
    local f="$TEST_ROOT/fixtures/20-git-aliases.sh"
    assert_eq "members" "gca gs" "$(alias_group_parse_members "$f")"
    assert_eq "hint for gca" "<message>" "$(alias_group_parse_hints "$f" | awk -F'	' '$1=="gca"{print $2; exit}')"
}

test_build_registry() {
    echo "test_build_registry"
    build_alias_group_registry "$TEST_ROOT/fixtures"
    assert_eq "order count" "3" "${#ALIAS_GROUP_ORDER[@]}"
    assert_eq "first is Git" "Git" "${ALIAS_GROUP_ORDER[0]}"
    assert_eq "second is Alias management" "Alias management" "${ALIAS_GROUP_ORDER[1]}"
    assert_eq "third is Docker" "Docker" "${ALIAS_GROUP_ORDER[2]}"
    assert_eq "resolve git" "Git" "$(resolve_group_name git)"
    assert_eq "resolve alias" "Alias management" "$(resolve_group_name aliases)"
    assert_eq "classify gs" "Git" "$(classify_group gs)"
    assert_eq "classify dps" "Docker" "$(classify_group dps)"
    assert_eq "members docker" "dps" "$(group_members Docker)"
    assert_eq "hint lookup" "<message>" "$(alias_hint_for gca)"
}
