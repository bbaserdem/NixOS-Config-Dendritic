# Development

This flake can, and should be used, as a development environment as well.
Not only used to configure operating systems, but also coding environments.

## Devshells

DevShell's are provided by this flake.
For programming projects; this is meant to serve devshells for development.

Keeping dev shells central helps with deduplication of packages across devshells.
Working with other people also becomes more convenient,
repos don't need to have nix files in them, reducing friction.
(This workflow works with untracked .envrc to initialize the devshells.)

Downside is, it's hard to get direnv to realize upstream changes in devShells if they are remote.
Either file reference to the local instance is used;
or use these commands to force a refresh;

```
nix develop --refresh github:bbaserdem/NixOS-Config-Dendritic#default
nix develop --refresh --option tarball-ttl 0 github:bbaserdem/NixOS-Config-Dendritic#default -c true
```

## Templates

Templates are provided by this flake.
Could be for anything, for now contains starter templates for coding projects.
These are prefixed with an underscore to prevent potential nix files from being loaded by this flake.
Since .gitignore files in templates might ignore other files, all files here have to be force-added to vcs.
