# Flake

The flake structure is inspired by [Doc-Steve](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)
but adapted to work with my systems.

## Usage

The flake ultimately configures systems.
Each machine is referred to as a `host`.
Hosts can have flake outputs defined for them.
This flake has helper functions to build outputs for configurations.

## Design Principles

This flake uses several principles for controlling the outputs.

### Dendritic Pattern

The main design of this flake is the dendritic pattern.
Dendritic pattern is a conceptual framework of designing system configuration.
Historically, I have been doing this by ad-hoc flake functions in my previous flake.
Dendritic pattern codifies this using [flake-parts](https://github.com/hercules-ci/flake-parts);
which is introducing the NixOS's module system to the flake specification.
(In my opinion; this should be adapted as a standard spec for flakes.)

The key concepts that are adopted from the dendritic pattern framework are;

- **Features**: Conceptial container for a functionality.
This is akin to, but not limited to, a software.
A feature can be set up across different *contexts*.
Features are characterized by their name; referred to as `<feature>`.
- **Aspects**: An implementation abstraction for a feature.
Most cases, this is the same as a *feature*, for most cases this is interchangable.
But the difference is; a *feature* is a conceptual container,
an an *aspect* is a unit contained under that feature.
Sometimes, a feature will contain different aspects.
An example would be a feature that is a single server and multiple client service.
It's one *feature* as in it's in one conceptual container.
However, there can be two *aspects* to this;
a `feature-server` *aspect* that serves this *feature*,
and a `feature-client` *aspect* that allows using the served *feature*.
- **Contexts**: Different situations that an *aspect* can manifest in.
In this flake, this will mostly be as `flake-parts modules`.
These modules are, most commonly but not limited to, `nixos`, `homeManager` and `darwin`.

So, in summation, a *feature* is a collection of *aspects*,
which for each *context* expose a `flake-parts module`.

### Classes

While not made explicit in this flake (yet),
I have organized *features* into several **classes**.
These are explained in detail in [the modules file hierarchy](###modules).

- **Systems**: Flake outputs; mostly configurations output by this flake.
- **Applications**: Programs that can be setup for personal use.
- **Services**: Programs that are serving functions beyond the scope of the system they are contained in.
- **Interfaces**: Entry points, containing personalizations. (Hosts and users)

### Local Configuration (as the upstream fixed point)

The wonderful functional paradigm of `nix` is very powerful.
But it's also very complex, and the way that it's implemented in contexts can cause issues.
The biggest issue I have faced is recursion; while having multiple modules talk with each other,
the way that the actual modules are built sometimes make it impossible to find a fixed point.
This is the source of infinite recursion errors.

My main solution to this issue is to have an upstream fixed point evaluated first,
which then propagates downstream, and becomes source of truth to all modules by this flake.
Thus we have a two stage evaluation; first a global config is evaluated into it's fixed point.
This is solving the infinite recursion problem by
using a *Causal Fork Model* to eliminate a *Causal Feedback Loop*.
(I pulled this description with AI)

This is materialized by a `flake-parts` option definition; `localConfig`.
When needed, config options are dispatched into `localConfig` first,
Then modules can access the config to set up their implementations.

Another solution to this problem was to use *factory functions*,
but I find this more elegant.
My solution isolates implementation to each *feature*,
while *factory functions* distribute implementation across features.
Downside is more complexity in nix code, but helps me learn functional programming so `¯\_(ツ)_/¯`.

## Folder Hierarchy

### Root

The root of this repo contains;

- `.envrc`: To auto-load the flake devshell.
- `book.toml`: Render this documentation
- `.sops.yaml`: SOPS configuration to access secrets

### Docs

Contains documentation for entire system management.

### Secrets

SOPS encrypted secrets live in this directory.
Each host gets their own `secrets.yaml` file, along with a shared across hosts file.
It's laid out the same for each user.
The sops files can be reached with `inputs.self + /secrets/...;`.

### Packages

This is where package outputs of this flake live.
Uses [pkgs-by-name-for-flake-parts](github.com/drupol/pkgs-by-name-for-flake-parts) to export packages.
The packages are available inside the flake in the `pkgs.local` namespace.

### Modules

Where the main bulk of the flake configuration lives.
This directory is roughly hierarchical;

#### modules/flake

Where the `flake-parts` and main inputs definition lives.
It's the entry point of the flake, any meta tools for organizing is defined here.

#### modules/hosts

Where host configuration resides.
Each host gets their own folder, and the entry points are here.

#### modules/apps

Modules for installing programs into the system.
Most nixos and darwin variants install the programs to shared home-manager space,
and do global configuration for them.
These modules are meant to be generic between users.
User specific configuration happens in users' spaces.

#### modules/wrappers

Programs that use [nix-wrapper-modules](github.com/birdee/nix-wrapper-modules) to configure them.
Useful for programs that have complex configuration options.

#### modules/systems

Configuration for specific systems that this flake can be deployed upon.
Contains configuration for frameworks shared between these systems as well.

#### modules/users

User configurations live here, along with helper config dispatchers for users.
Each user exports modules with it's user name, which contains their personal config.

When putting configuration, it's useful to put enable guards liberally;
since the user module can be dispatched to multiple machines that might or might not have certain features.

#### modules/devshells

DevShell's provided by this flake.
For my programming projects; this is meant to serve devshells for development.

Keeping dev shells central helps with deduplication of packages across devshells.
Working with other people also becomes more conveniont,
repos don't need to have nix files in them, reducing friction.
(This workflow works with untracked .envrc to initialize the devshells.)

Downside is, it's hard to get direnv to realize upstream changes in devShells if they are remote.
Either file reference to the local instance is used;
or use these commands to force a refresh;

```
nix develop --refresh github:bbaserdem/NixOS-Config-Dendritic#default
nix develop --refresh --option tarball-ttl 0 github:bbaserdem/NixOS-Config-Dendritic#default -c true
```

#### modules/templates

Templates provided by this flake.
Could be for anything, for now contains starter templates for coding projects.
These are prefixed with an underscore to prevent potential nix files from being loaded by this flake.
Since .gitignore files in templates might ignore other files, all files here have to be force-added.
