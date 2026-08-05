# Bash Aliases

A modular Bash aliasing system: drop group files under `~/.bash/aliases/`,
source them from `~/.bash_aliases`, and manage them with helpers like
`add-alias`, `edit-alias`, `list-aliases`, and `reload-aliases`.

Groups are derived from files — one `20-*.sh` … `99-*.sh` file is one group.
No central membership list to keep in sync.

## What you get

- Lexicographic loader with numeric prefixes for load order
- File-equals-group registry (display name, filter keys, members, hints)
- Management commands: `add-alias`, `edit-alias`, `delete-alias`, `list-aliases`, `list-alias-groups`, `check-alias-groups`, `reload-aliases`
- Git shortcuts and safer wrappers (`push-all`, `tag-push`, `undo-last-commit`)
- Themed groups (System / Homebrew, MkDocs, …) as separate group files

## Next steps

- [Getting started](getting-started.md) — install into your shell
- [Usage](usage.md) — everyday commands and workflows
- [Reference](reference.md) — layout, headers, and public commands
- [Examples](examples.md) — add, edit, delete, and create groups
