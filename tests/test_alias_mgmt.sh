#!/usr/bin/env bash
# shellcheck shell=bash
# Sourced by run-tests.sh after 00-config.sh

test_alias_quote_and_format() {
    echo "test_alias_quote_and_format"
    assert_eq "no quotes" "alias foo='bar'" "$(alias_format_line foo bar | tr -d '\n')"
    local got
    got=$(alias_format_line foo "it's" | tr -d '\n')
    assert_eq "embed quote" "alias foo='it'\\''s'" "$got"
}

test_alias_next_group_nn() {
    echo "test_alias_next_group_nn"
    local dir
    dir=$(mktemp -d)
    touch "$dir/20-alias-management.sh" "$dir/30-git-aliases.sh" "$dir/90-other-aliases.sh"
    assert_eq "next tens slot" "40" "$(alias_next_group_nn "$dir")"
    rm -rf "$dir"
}

test_alias_file_roundtrip() {
    echo "test_alias_file_roundtrip"
    local dir file
    dir=$(mktemp -d)
    export BASH_ALIAS_DIR="$dir"
    file=$(alias_create_group_file "$dir" "docker")
    assert_eq "first free nn" "20" "$(basename "$file" | cut -d- -f1)"

    alias_append_to_file "$file" "dps" "docker ps"
    build_alias_group_registry "$dir"
    assert_eq "members after add" "dps" "$(group_members Docker)"
    assert_eq "file for name" "$file" "$(alias_group_file_for_name dps)"

    alias_replace_in_file "$file" "dps" "docker ps -a"
    if grep -Fq "docker ps -a" "$file"; then
        assert_eq "replace command" "ok" "ok"
    else
        assert_eq "replace command" "ok" "missing"
    fi

    {
        printf '%s\n' '# @group: Docker'
        printf '%s\n' '# @keys: docker'
        printf '%s\n' '# @hint <all>'
        alias_format_line dps "docker ps -a"
    } >"$file"

    alias_remove_from_file "$file" "dps"
    if grep -q 'alias dps=' "$file"; then
        assert_eq "alias removed" "gone" "present"
    else
        assert_eq "alias removed" "gone" "gone"
    fi
    if grep -q '@hint' "$file"; then
        assert_eq "hint removed with alias" "gone" "present"
    else
        assert_eq "hint removed with alias" "gone" "gone"
    fi
    rm -rf "$dir"
}
