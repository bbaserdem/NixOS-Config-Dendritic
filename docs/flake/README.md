# Flake

This flake defines my system configurations, and shared functionality across them.
Main frameworks used are;

- [Flake-Parts Framework](https://github.com/hercules-ci/flake-parts):
  Enables the usage of module systems, initially native to NixOS, on the full flake level.
- [Dendritic Pattern, explained by Doc-Steve](https://github.com/Doc-Steve/dendritic-design-with-flake-parts):
  Conceptual organization of how system can be configured.
- [Den Framework](https://github.com/denful/den):
  Aspect Oriented Programming paradigm to realize the dendritic pattern for system configuration.

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
The design concepts are produced across frameworks,
and I try to align with their terminology as much as possible.
The concepts I use are the following;

- **Features**: Conceptial container for a functionality.
  This is akin to, but not limited to, a software.
  A feature can materialize across different _entities_.
  Features are characterized by their name; referred to as `<feature>`.
- **Aspects**: An implementation abstraction for a feature.
  (Comes from the same _aspect_ concept in `den`.)
  Most cases, this is the same as a _feature_, for most cases this is interchangable.
  But the difference is; a _feature_ is a conceptual container,
  an an _aspect_ is a unit contained under that feature.
  Sometimes, a feature may contain different aspects.
  An example would be a feature that is a single server and multiple client services.
  It's one _feature_ as in it's in one conceptual container.
  However, there can be two _aspects_ to this;
  a `feature-server` _aspect_ that serves this _feature_,
  and a `feature-client` _aspect_ that allows using the served _feature_.
- **Contexts**: Different situations that an _aspect_ can manifest in.
  This corresponds to _entity kinds_ in `den`, and realized as _modules_
  for a `flake-parts` _class_ (_module_ evaluation domain; canonically
  `nixos`, `darwin`, `homeManager`)

So, in summation, a _feature_ is one, or many, _aspects_,
which for each _context_ expose a `flake-parts module` or equivalent.

### Classes

I personally organized my _features_ into several **types**.

- **Systems**: Flake output types; mostly configurations output by this flake.
  Unlike _entity kind_ this is more a concept; such as standard _MacOS_ desktop,
  A _NixOS_ desktop, _liveusb_, _Raspberry Pi_ etc.
- **Frameworks**: Programs that provide systems with broad range of capabilities.
  Such as _disko_, _sops_ etc.
- **Applications**: Programs that can be setup for one on one interactive use.
  User facing apps, such as _mpd_, _obsidian_ etc.
  Applications have `domains` such as _documents_, _music_ etc.
- **Utilities**: Not exactly programes, but more like runners and processes.
  Things such as _networkmanager_, _avahi_ etc.
- **Services**: Programs that are _serving_ functions, not just direct point of contact.
  Things such as _syncthing_, _paperless_ etc.
