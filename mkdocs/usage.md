# Usage

## List aliases

```bash
list-aliases              # all groups
list-aliases git          # one group (filter token)
list-alias-groups         # canonical names + accepted keys
```

Filter tokens come from each file’s default key or `# @keys:` header
(for example `git`, `system`, `mkdocs`, `alias`, `other`).

## Add an alias

```bash
add-alias system dfh 'df -h'          # existing group
add-alias docker dps 'docker ps'      # creates NN-docker.sh if needed
```

`<group>` is a filter token from `list-alias-groups`, or a new slug. New
groups get the next free `NN` prefix (preferring 20, 30, … 80) and a header
with `# @group` / `# @keys`. The alias is defined in the current session and
the registry is refreshed (no separate `reload-aliases` required).

## Edit an alias

```bash
edit-alias dfh 'df -hT'
edit-alias dfh                        # prompts for the new command
```

Updates the `alias` line in the group file that owns the name. Any `# @hint`
on the previous line is left in place.

## Delete an alias

```bash
delete-alias dfh --session            # this shell only
delete-alias dfh --file               # remove from group file + session
delete-alias dfh                      # interactive: session vs file
```

`--file` also drops a preceding `# @hint` line when present.

## Reload after hand edits

```bash
reload-aliases
```

Use this when you edit group files in an editor. The add/edit/delete helpers
already refresh the registry themselves.

## Sanity check

```bash
check-alias-groups
```

Confirms each registered group file is readable and each discovered
member alias is defined after load.

## Git helpers

Common shortcuts live in `30-git-aliases.sh` (`gs`, `gl`, `gca`, …).
Parameterized wrappers:

| Command                    | Behaviour                                     |
| -------------------------- | --------------------------------------------- |
| `push-all <message>`       | Stage all, commit, optionally push            |
| `tag-push <tag> [message]` | Annotated tag + `git push --tags`             |
| `undo-last-commit`         | Soft reset last commit (keeps changes staged) |
