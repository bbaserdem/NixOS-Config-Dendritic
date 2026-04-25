# Systems

## NixOS

## MacOS

- [**Su Ana**](../hardware/su-ana.md) is the Macbook pro for `wolf-ramite`; used for work purposes.
- **TBD** is the Macbook for `joeysaur`; daily driver.

I wouldn't be caught dead using a mac product before work requirements,
but I'll admit that ARM laptop with optimized firmware is unbeatable.
Infinite battery life, no thermal issues. Chef's kiss.

We manage the MacOS installation with nix-darwin as much as possible.

### MacOS Caveats

- `nix-darwin` doesn't contain [syncthing](../software/syncthing.md), so it's set at user level.
- Systems built to accomodate multi-user setup, but not guaranteed.

### MacOS Setup

Prequisite steps for system management;

- Setup computer with desired username, login to apple account.
- Use the Lix installer to install nix.
- Install homebrew
- Install XCode
- Boot in recovery mode, log into hard drive as recovery, enable kernel extensions.

## Virtual Machines
