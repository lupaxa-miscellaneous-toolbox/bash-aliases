# Getting started

## Requirements

- Bash (macOS `/bin/bash` 3.2 or newer is fine)
- Optional: Git, for the Git alias group

## Install

Clone this repository (or keep your existing checkout), then point your home
aliases at the repo files. Symlink:

```bash
ln -sfn /path/to/bash-aliases/.bash_aliases ~/.bash_aliases
ln -sfn /path/to/bash-aliases/.bash ~/.bash
```

Or copy `.bash_aliases` and `.bash/aliases/` into `$HOME`.

Ensure `~/.bashrc` (or your login shell init) sources the loader:

```bash
# -------------------------------------------------------------------
# Aliases & Git completion
# -------------------------------------------------------------------
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```

Open a new shell, or run:

```bash
source ~/.bash_aliases
```

## Verify

```bash
list-alias-groups
list-aliases
check-alias-groups
```

You should see groups such as **Alias management**, **Git**, **System**,
**MkDocs**, and **Other**, with portable example aliases (for example `gs`,
`ll`, `mkdocs-serve`). Treat those as a starter pack — edit or delete freely.

## Try the helpers

```bash
add-alias other hello 'echo hi'
list-aliases other
edit-alias hello 'echo hello'
delete-alias hello --file
```

## Development extras

Docs and Makefile skills (optional):

```bash
make init
python -m pip install -r requirements.txt
make mkdocs-serve
```

Registry unit tests:

```bash
bash tests/run-tests.sh
```
