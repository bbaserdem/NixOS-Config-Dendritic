# Flake

The flake structure is inspired by [Doc-Steve](https://github.com/Doc-Steve/dendritic-design-with-flake-parts)
but adapted to work with my systems.

## Usage

The flake ultimately configures systems.
Each machine is referred to as a `host`.
Hosts can have flake outputs defined for them.
This flake has helper functions to build outputs for configurations.



---



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

I personall organized *features* into several **classes**.

- **Systems**: Flake outputs; mostly configurations output by this flake.
- **Applications**: Programs that can be setup for one on one interactive use.
- **Services**: Programs that are serving functions, not direct point of contact they are contained in.
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

Documented [here](./config.md).



---



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



---



## Modules

Modules are the bulk of this flake.
This flake generates many `flake-parts.modules`.
These modules are meant to be invoked into **interfaces**;
which essentially means they are going into the `imports` list
of a host or a users' configuration.


### System Modules

System modules, naming convention prefixes them with `system-`.

The **system** class refers to either a specific flake output,
or any `feature` that is cross cutting the entirety of the flake.

These should be composable with each other for the most part.


- `system-nixos`: User-facing NixOS instance, configures a full system.
- `system-vm[-<amd/arm>]`: Virtual NixOS image generation.
- `system-macos`: Nix Darwin configuration system.
- `system-hm`: Home Manager configuration (for standalone usage).
- `system-homeManager`: Home Manager configuration for controlling nixos/macos users.
- `system-shell`: Shell environment setup.
- `system-nix`: Nix daemon configuration
- `system-sops`: Framework for dispatching secrets across flake outputs.
- `system-stylix`: Unified styling configuration framework.


### Application Modules

Application modules, naming convention should prefix with `app-`.

The modules set up specific apps.

Then there are bundles too; they can use a naming convention `apps-<bundle>[-<variant>]`

- `apps-music-full`: Entire music application suite
- `apps-music-mpd`: Bundle of apps that setup local mpd.
- `apps-music-curator`: Bundle of apps used to manage music library.
- `apps-docs-base`: A quick app list for basic document functionality
- `apps-docs-full`: Full document management bundle.


### Service Modules

Service modules, service to be served from a host; naming prefix is `service-`.


### Host Modules

Host modules, naming prefix is `host-`.


### User Modules

User modules, naming prefix is `user-`.
Complex setup of a user should be collected under `user-<user>-<feature>`




