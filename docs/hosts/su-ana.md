# Su Ana

_Su Ana; goddess of water._

**Su Ana** is my work laptop.

## Hardware

Macbook pro; used for work purposes.

## Setup

Deployment is ad-hoc due to being a MacOS computer,
and there are things I need that are not possible via nix.

### Pre-Deployment

First, every mac needs to be imperatively setup and log into their apple account.
The user account info and hostname must match this flake, but otherwise
it's pretty straightforward.

- Install `nix`, either via `lix` or official `nix`.
  Official nix mainlined the DeterminateSystems installer, so should be usable.
- Install `homebrew`; as nix can't install it.
- Enable kernel extensions for some file system packages.
  `macfuse` recommends [this guide](https://developer.apple.com/library/archive/technotes/tn2459/_index.html).

### External needed software

Right now, work requires the following software not integrable to nix deployment.

- WorkSmart; install from crossover platform, works just fine.
- Nessie; from [their website](https://nessielabs.com/).
  Nessie does clobber some settings, but need to deal with this later on.

### Nix-Darwin

It should take one activation; the command to run should be;

```
sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch
```

Could also try this;

```
nix run nix-community/nh -- darwin switch 'git+https://codeberg.org/baserdemb/SystemConfigFlake.git'
```

### Post Setup

Things should work outside the box; syncthing allows for file sharing so it should be fine.

## Quirks

### AI Features

Apple is aggressive with AI features and visibility; as seen in;

- [hackernews discussion](https://news.ycombinator.com/item?id=49790409)
- [link from there](https://archive.ph/AE72I#selection-712.0-731.53)
- [pared](https://4evy.github.io/) nix-darwin integrated tooling for this.

Pared is included in default `MacOS`; and should be configured and used.
