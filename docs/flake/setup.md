# Flake Setup

Usage inside this flake.

---

## Flake-Parts

Main scaffold for this flake is `flake-parts`.

- _modules_ is where flake-parts modules live.
- Any module here is imported by [import-tree](TODO: link)
- Flake inputs are auto-generated from `config.flake-inputs` by [flake-inputs](TODO: link).
- Flake-wide metadata is stored in `localConfig`.

---

## Packages

`packages` directory contains custom packages exported by this flake.
Arguments to `TODO: what is this exactly?` are to be the files.
We use [pkgs-for-flake-parts](TODO: url) to auto export packages.

---

## Den

Den is used to create system configuration with shared topology.

Custom classes are;

- `stylix` and `stylixOs`: injects the setting to proper `config.stylix` block.

> [!WARNING]
> (AI made plan)
>
> ## Stylix intersection classes (`stylixOs` / `stylix`) — provisional wiring
>
> The custom den classes for stylix target intersection are wired via **guarded
> route policies** (`den.lib.policy.route` + `guard`), mirroring den's built-in
> `os-to-host` policy. Delivery is _scope-local_: content emitted at host scope
> routes into the host's OS eval; content emitted at user scope routes into that
> user's `home-manager` eval. The `guard = {options, ...}: options ? stylix`
> probe replaces the legacy `hasAttrByPath` sprinkle — one gate, at the edge.
>
> **Verified from den source (v0.18.0 / rev `5df0987`):**
>
> - `route` accepts `fromClass`/`intoClass`/`intoPath`/`guard`
>   (`nix/lib/policy-effects.nix:49-58`, guard is class-source-only).
> - False guards contribute nothing (`guardModule`, `fx/edges/route.nix:135`).
> - Scope-local collection is how `os-class.nix` works — precedented path.
>
> **NOT yet verified by eval (revisit before relying on it):**
>
> 1. `intoPath = ["stylix"]` nesting lands where expected in the target eval.
> 2. Guard behavior on a host _without_ `den.aspects.stylix`
>    (test: drop stylix from a host's includes; eval must still pass).
> 3. The HM-side route end-to-end — **blocked on the first den user entity**
>    (`…home-manager.users.<u>.stylix.targets.<t>.enable`).
> 4. Merge precedence when a target eval sets the same option directly.
>
> **Why route, not the forward battery:** `forward`'s `fromAspect` re-resolves
> ONE aspect's graph; feature-carried content selected via `provides.to-users`
> (case: host gives kitty to all users) escapes it. Route collects per-scope.
> Field reference for the forward alternative: `Gwenodai/nixos`
> `modules/aspects/core/preservation/class/classes.nix`.
>
> **Interim rule until verified:** themed features may use the inline fallback
> `config = lib.mkIf (options ? stylix) { stylix.targets.<t>.enable = true; };`
> inside the appropriate class module — mechanically upgradable to the class
> keys later. Decision table for which class a target belongs to: see the
> stylix framework commentary (`modules/frameworks/stylix.nix`).

---

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

---

## Templates

Templates are provided by this flake.
Could be for anything, for now contains starter templates for coding projects.
These are prefixed with an underscore to prevent potential nix files from being loaded by this flake.
Since .gitignore files in templates might ignore other files, all files here have to be force-added to vcs.
