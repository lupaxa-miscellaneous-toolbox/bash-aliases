# Examples

## Add an alias to an existing group

```bash
add-alias system ducks 'du -sh *'
list-aliases system
```

Catch-all one-offs:

```bash
add-alias other weather 'curl -fsS wttr.in'
```

## Create a new group

```bash
add-alias docker dps 'docker ps'
add-alias docker dcu 'docker compose up -d'
list-alias-groups
list-aliases docker
```

The first `add-alias` for an unknown group slug creates `NN-docker.sh` with
`# @group` / `# @keys` headers. You can still create files by hand if you want
extra keys (for example `dk`).

## Edit and delete

```bash
edit-alias dps 'docker ps -a'
delete-alias dps --file
```

Session-only delete (group file unchanged):

```bash
delete-alias dps --session
```

## Point Homebrew Bundle at your Brewfile

```bash
# in ~/.bashrc, before sourcing ~/.bash_aliases
export BREWFILE="$HOME/dotfiles/Brewfile"
```

Then `export-brew` / `import-brew` use that path.

## Document a parameterized alias

Hand-edit the group file (helpers do not write `@hint` yet):

```bash
# @hint <service>
alias dcl='docker compose logs -f'
```

Then `reload-aliases`. `list-aliases docker` shows `dcl <service>`.

## Run the registry tests

From a checkout of this repo:

```bash
bash tests/run-tests.sh
```
