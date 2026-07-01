# Modules

Modules are the bulk of this flake.
This flake generates many `flake-parts.modules`.
These modules are meant to be invoked into **interfaces**;
which essentially means they are going into the `imports` list
of a host or a users' configuration.

## Classes

Initially, I have been using **feature** only naming for modules.
Which does get complicated very fast.
I adopted a new naming scheme; that is; `<class>-<feature>[-<sub-feature>]`

### System Modules

System modules, naming convention prefixes them with `system-`.

The **system** class refers to either a specific flake output,
or any `feature` that is cross cutting the entirety of the flake.

These should be composable with each other for the most part.

- `system-nixos`: User-facing NixOS instance, configures a full system.
- `system-vm[-<amd/arm>]`: Virtual NixOS image generation.
- `system-macos`: Nix Darwin configuration system.
- `system-hm`: Home Manager configuration for controlling nixos/macos users.
- `system-hm-standalone`: Home Manager configuration for standalone usage.
- `system-shell`: Shell environment setup.
- `system-nix`: Nix daemon configuration
- `system-sops`: Framework for dispatching secrets across flake outputs.
- `system-stylix`: Unified styling configuration framework.

### Utility modules

Modules that configure certain functionalities; without being user facing.
Mostly context dependent, with naming convention `utility-`.

- `utility-networkmanager`: Configures automatic network configuration

### Application Modules

Application modules, naming convention should prefix with `app-`.

The modules set up specific apps.

Apps have _bundles_ too; pre-made collection of individual apps.
They use the naming convention `apps-<bundle>[-<variant>]`

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
