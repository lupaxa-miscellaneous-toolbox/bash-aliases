<p align="center">
    <a href="https://github.com/lupaxa-miscellaneous-toolbox">
        <img src="https://raw.githubusercontent.com/the-lupaxa-project/brand-assets/master/logos/organisations/miscellaneous-toolbox/readme-logo.png" alt="Organisation Logo" />
    </a>
</p>

<h1 align="center">Bash Aliases</h1>

Modular Bash aliases with **file-equals-group** organisation: one group file
under `~/.bash/aliases/` is one group. Manage them with `add-alias`,
`edit-alias`, `delete-alias`, `list-aliases`, and `reload-aliases`, plus Git
and system quality-of-life shortcuts.

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

## Manage aliases

```bash
add-alias system dfh 'df -h'         # existing group (token from list-alias-groups)
add-alias docker dps 'docker ps'     # creates NN-docker.sh if the group is new
edit-alias dfh 'df -hT'              # update the command in its group file
delete-alias dfh --file              # remove from file + this session
delete-alias dfh --session           # this shell only
delete-alias dfh                     # interactive: session vs file
```

Hand-editing group files (`30-git-aliases.sh`, `40-system.sh`, …) still works;
run `reload-aliases` afterwards.

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
