# Deployment

Guide into deploying the system configuration flake to different machines.
There are two ways for installing NixOS;

- [Local installation, using `disko`](#disko-install)
- [Remote installation, using `nixos-anywhere`](#nixos-anywhere)

MacOS doesn't really let you install it through `nix`,
but it can be [configured with `nix-darwin`](#darwin-nix-setup).

---

## Install NixOS locally with `disko-install` {: #disko-install}

The first item is to use `Kayra`; the live USB, to boot into this computer.
As of now, `Kayra` is a live-iso, output into the package outputs.
We are using `MultiOS-USB` to boot this system.

The steps are;

1) Boot into live environment
2) Connect to internet and sync
3) Mount encrypted key vault
4) Setup for LUKS
5) Confirm setup
6) Install

> [!WARNING]
> Change Kayra from liveiso to an on ramdisk but local to usb installation.
> Right now, MultiOS-USB support (needs scripted boot by /boot/grub/loopback.cfg)
> is deprecated; and unknown whether Ventoy can deal with this either.
> Switching to an impermanent setup where the OS is kept on the usb,
> and loaded into RAM would be a more maintainable (and secret deployable) solution.
> This would also enable LUKS encryption, so we could deploy secrets here as well.

### Boot into live environment
[^note]: As of now, the live environment is supplied by
    [MultiOS-USB](https://github.com/Mexit/MultiOS-USB) formatted drive,
    containing the [Kayra](../hardware/kayra.md) iso.

This should be simple, enter uefi selection menu, choose the right option.

### Connect to internet and sync

Live environment should have a GNOME desktop, top right should allow opening the wifi menu.

```
# This command should exist in the live environment
flake-sync
# CD to flake directory
cd-flake
```

> {!IMPORTANT}
> From now on, the workflow assumes you are inside the flake directory.
> Adjust accordingly.

### Mount encrypted key vault

The USB used for the installation should have a `gocryptfs` encrypted folder,
and `kayra` should have the proper tools pre-installed to perform this;

```
udisksctl mount --block-device=/dev/<usb-device>
mkdir _crypt
gocryptfs /run/media/sbp/<Device>/KeyVault _crypt
```

> [!NOTE]
> In the vault, there should be a `Systems` and `LUKS` directory.

### Setup for LUKS

Put the needed LUKS key files in `/tmp`, and create a passphrase file `/tmp/<HostName>.key`.
Disko expects the LUKS information in this location.

> [!TIP]
> Check the flake for the `disko` config for which files are needed.
> Should be pretty intuitive though.

### Confirm setup

Check if the specified disk in the configuration exists.

> [!CAUTION]
> *Optional* & ***DESTRUCTIVE***; test out whether disko works.
> Command is `disko --mode disko --flake .#<hostname>`

### Install

Run the `disko-install` command.

```
sudo disko-install \
  --flake .#<hostname> \
  --extra-files _crypt/Systems/<hostname>
  --disk Linux /dev/...
```

> [!TIP]
> There is a `--dry-run` command to check operations before starting.

> [!IMPORTANT]
> The `--disk` argument needs to be repeated for each configured disk.

---

## Install NixOS remotely using `nixos-anywhere` {: #nixos-anywhere}

TODO: Do this part

---

## Set MacOS with `nix-darwin` {: #darwin-nix-setup}

TODO: Do this part
