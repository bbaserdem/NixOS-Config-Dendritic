# Deployment

Guide into deploying the system configuration flake to different machines.
There are two ways for installing NixOS;

- [Local installation, using `disko`](#disko-install)
- [Remote installation, using `nixos-anywhere`](#nixos-anywhere)

MacOS doesn't really let you install it through `nix`,
but it can be [configured with `nix-darwin`](#darwin-nix-setup).

After deployment, [post-installation](#post-installation) steps should be followed.

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
> Also need to set up copytoram to the live isos so they are hotplugabble.

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

> [!IMPORTANT]
> From now on, the workflow assumes you are inside the flake directory.
> Adjust accordingly.

### Mount encrypted key vault

The USB used for the installation should have a `gocryptfs` encrypted folder,
and `kayra` should have the proper tools pre-installed to perform this;

```
udisksctl mount --block-device=/dev/<usb-device-partition>
mkdir _crypt
gocryptfs -ro -allow_other /run/media/sbp/<Device>/KeyVault _crypt
```

> [!NOTE]
> In the vault, there should be a `Systems` and `LUKS` directory.

### Setup for LUKS

Put the needed LUKS key files in `/tmp`.
The key files should be in `_crypt/LUKS/<HostName>_<Disk>.key`
Create a passphrase file `/tmp/<HostName>.key`, for the manual passwords.
Disko expects the LUKS information from these locations.

> [!TIP]
> Check the flake for the `disko` config for which files are needed,
> but this should be pretty intuitive already.

### Confirm setup

Check if the specified disk in the configuration exists.

> [!CAUTION]
> *Optional* & ***DESTRUCTIVE***; test out whether disko works by writing disko.
> Command is `sudo disko --mode destroy,format,mount --flake .#<hostname>`
> Can also add `--dry-mount` flag to test operations.

### Install

Run either the `disko-install` command;

```
sudo disko-install \
  --flake .#<hostname> \
  --extra-files "_crypt/Systems/<hostname>/." "/" \
  --write-efi-boot-entries \
  --disk Linux /dev/...
```

> [!TIP]
> There is a `--dry-run` flag to check operations before starting.
> For doing dry run, if getting out of space error, increase tmpfs size;
> `sudo mount -o remount,size=24G /nix/.rw-store`
> (Here, 24G is a suggestion)

> [!TIP]
> There is a `--write-efi-boot-entries` flag to create boot entries,
> or omit if not wanted.

> [!IMPORTANT]
> The `--disk` argument needs to be repeated for each configured disk.

> [!NOTE]
> There might not be enough RAM; liveiso exposes 50% of RAM as store space
> and disko-install tries to build the full closure on disk first.
> In this case, might just want to mount with disko, and install with nixos-install.
> (Keys need to be copied manually in this case)
> `sudo disko --mode mount --flake .#<hostname>`, then
> `sudo cp -a _crypt/Systems/<hostname>/. /mnt/`, then
> `sudo nixos-install --root /mnt --flake .#yel-ana --no-channel-copy --no-root-password --no-write-lock-file`
> (The `initrdUnlock = false` partitions need to be manually opened.)

---

## Install NixOS remotely using `nixos-anywhere` {: #nixos-anywhere}

`kayra` and `mergen` are the live environments that allow remote access to hardware.
First step is getting the drive that can boot into it;
discussed in [the previous section](#disko-install).

Then a layout of the steps are;

1) Boot into live environment, and connect to internet.
2) Prepare controller machine environment
3) Install remotely

### Boot into live environment and connect to network

Should be pretty straightforward for this step.
This is done on the host machine; this has to happen here.

### Prepare controller machine environment

This should more or less be set up at the user `wolframite`.
For machines not already setup with this user; this would basically be;

- Local clone the flake repo
- Grab the ssh private key to the liveiso
- Load the encrypted keyvault with `gocryptfs`

> [!IMPORTANT]
> From now on, the workflow assumes you are inside the flake directory,
> and the keyvault is opened to `_crypt`
> Adjust accordingly.

### Install Remotely

The command to issue in the dispatcher system is;

```
nixos-anywhere \
    --flake .#<hostname> \
    --target-host "<liveiso>" \
    --build-on auto
    --phases kexec.disko,install \
    --disko-mode disko \
    --no-disko-deps \
    --extra-files "_crypt/Systems/<hostname>" \
    --disk-encryption-keys "/tmp/<HostName>_<Disk>.key" "_crypt/LUKS/<HostName>_<Disk>.key"
    
```

> [!IMPORTANT]
> The `--disk-encryption-keys` flag needs to issued multiple times for each
> key file disko expects.

> [!TIP]
> For getting the ssh key, the public.asc in repo assets can be used to register
> the GPG keys from yubikey, which should allow decrypting the private ssh
> key from the SOPS files.
> This will need to use `--target-host root@<liveiso>.local -i <private-key>`
> instead of the `--target-host <liveiso>` stanza.

> [!TIP]
> If disko already ran, can change the flag to `--disko-mode mount`

> [!TIP]
> `--build-on remote` builds the system on the live-usb, useful to skip cross-compilation.
> `--build-on local` builds the system on the local machine, might be nice to specify.

---

## Set MacOS with `nix-darwin` {: #darwin-nix-setup}

TODO: Do this part

---

## Post Installation Steps {: #post-installation}

Some setup after deployment might be necessary.
This is a list of post-install steps to follow.

### Backup LUKS headers

TODO: Do this part

### Register user GPG key with YubiKey

Insert yubikey, and run `gpg --card-status` as user for the GPG keys.

### User Setup

If applicable, following steps will onboard a user to user the computer;

- Log in to Mozilla Sync
