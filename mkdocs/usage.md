# Usage

## List aliases

```bash
list-aliases              # all groups
list-aliases git          # one group (filter token)
list-alias-groups         # canonical names + accepted keys
```

Filter tokens come from each file’s default key or `# @keys:` header
(for example `git`, `system`, `mkdocs`, `alias`, `other`).

## Example aliases shipped with this repo

| Group   | Alias            | Command / notes                                      |
| ------- | ---------------- | ---------------------------------------------------- |
| Git     | `gs`             | `git status -sb`                                     |
| Git     | `gl`             | compact decorated log                                |
| Git     | `push-all`       | stage, commit, confirm push                          |
| System  | `dfh`            | `df -h`                                              |
| System  | `export-brew`    | dump Brewfile to `$BREWFILE` (default `~/Brewfile`)  |
| System  | `import-brew`    | `brew bundle` from `$BREWFILE`                       |
| MkDocs  | `mkdocs-serve`   | `mkdocs serve`                                       |
| MkDocs  | `mkdocs-build`   | `mkdocs build --strict`                              |
| MkDocs  | `mkdocs-lan`     | serve on `0.0.0.0:8000`                              |
| Other   | `ll` / `la`      | long / almost-all listings                           |
| Other   | `mkcd`           | mkdir + cd                                           |

Override the Brewfile path before loading aliases if needed:

```bash
export BREWFILE="$HOME/config/Brewfile"
```

## Add an alias

```bash
add-alias system ducks 'du -sh *'     # existing group
add-alias docker dps 'docker ps'      # creates NN-docker.sh if needed
```

`<group>` is a filter token from `list-alias-groups`, or a new slug. New
groups get the next free `NN` prefix (preferring 20, 30, … 80) and a header
with `# @group` / `# @keys`. The alias is defined in the current session and
the registry is refreshed (no separate `reload-aliases` required).

## Edit an alias

```bash
edit-alias ducks 'du -sh * | sort -h'
edit-alias ducks                      # prompts for the new command
```

Updates the `alias` line in the group file that owns the name. Any `# @hint`
on the previous line is left in place.

## Delete an alias

```bash
delete-alias ducks --session          # this shell only
delete-alias ducks --file             # remove from group file + session
delete-alias ducks                    # interactive: session vs file
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
