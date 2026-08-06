<p align="center">
    <a href="https://github.com/lupaxa-workstation-toolbox">
        <img src="https://raw.githubusercontent.com/the-lupaxa-project/brand-assets/master/logos/organisations/workstation-toolbox/readme-logo.png" alt="Organisation Logo" />
    </a>
</p>

<h1 align="center">Bash Aliases</h1>

A **file-equals-group** Bash alias starter pack you can fork and extend. One
group file under `~/.bash/aliases/` is one group. Ships example Git, system,
MkDocs, and catch-all aliases, plus helpers: `add-alias`, `edit-alias`,
`delete-alias`, `list-aliases`, and `reload-aliases`.

## Install

Symlink (or copy) into your home directory:

```bash
ln -sfn "$PWD/.bash_aliases" ~/.bash_aliases
ln -sfn "$PWD/.bash" ~/.bash
```

Source from `~/.bashrc`:

```bash
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```

Then `source ~/.bash_aliases` or open a new shell.

## Quick check

```bash
list-alias-groups
list-aliases
check-alias-groups
```

## Example aliases included

| Group            | Examples                                              |
| ---------------- | ----------------------------------------------------- |
| Alias management | `list-aliases`, `add-alias`, `edit-alias`, …          |
| Git              | `gs`, `gl`, `gca`, `push-all`, `tag-push`, …          |
| System           | `dfh`, `brew-outdated`, `export-brew` → `~/Brewfile`  |
| MkDocs           | `mkdocs-serve`, `mkdocs-build`, `mkdocs-lan`          |
| Other            | `ll`, `la`, `mkcd`, `myip`                            |

Homebrew Bundle helpers read/write `$BREWFILE` (default `~/Brewfile`). Override
in `~/.bashrc` if you keep a Brewfile elsewhere.

## Manage aliases

```bash
add-alias system ducks 'du -sh *'    # existing group (token from list-alias-groups)
add-alias docker dps 'docker ps'     # creates NN-docker.sh if the group is new
edit-alias ducks 'du -sh * | sort -h'
delete-alias ducks --file            # remove from file + this session
delete-alias ducks --session         # this shell only
delete-alias ducks                   # interactive: session vs file
```

Hand-editing group files still works; run `reload-aliases` afterwards.

## Group layout

| File                       | Group            |
| -------------------------- | ---------------- |
| `20-alias-management.sh`   | Alias management |
| `30-git-aliases.sh`        | Git              |
| `40-system.sh`             | System           |
| `50-mkdocs.sh`             | MkDocs           |
| `90-other-aliases.sh`      | Other (catch-all)|

## Development

```bash
make init
python -m pip install -r requirements.txt
bash tests/run-tests.sh
make mkdocs-serve
```

<a href="https://github.com/the-lupaxa-project">
  <img src="https://raw.githubusercontent.com/the-lupaxa-project/brand-assets/master/logos/components/footer-for-child-orgs.svg" alt="The Lupaxa Project Footer" width="100%" />
</a>
