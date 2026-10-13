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

1. Boot into live environment
2. Connect to internet and sync
3. Mount encrypted key vault
4. Setup for LUKS
5. Confirm setup
6. Install

> [!WARNING]
> Change Kayra from liveiso to an on ramdisk but local to usb installation.
> Right now, MultiOS-USB support (needs scripted boot by /boot/grub/loopback.cfg)
> is deprecated; and unknown whether Ventoy can deal with this either.
> Switching to an impermanent setup where the OS is kept on the usb,
> and loaded into RAM would be a more maintainable (and secret deployable) solution.
> This would also enable LUKS encryption, so we could deploy secrets here as well.
> Also need to set up copytoram to the live isos so they are hotplugabble.

### Boot into live environment

[^note]:
    As of now, the live environment is supplied by
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
The key files should be in `_crypt/Systems/<hostname>/etc/cryptsetup-keys.d/<HostName>_<Disk>.key`,
copy them to `/tmp/*.key`.
Create a passphrase file `/tmp/<HostName>.key`, for the manual password.
Disko expects the LUKS information at these locations.

> [!TIP]
> Check the flake for the `disko` config for which files are needed,
> but this should be pretty intuitive already.

### Confirm setup

Check if the specified disk in the configuration exists.

> [!CAUTION]
> _Optional_ & _**DESTRUCTIVE**_; test out whether disko works by writing disko.
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
> `sudo nixos-install --root /mnt --flake .#yel-ana --no-channel-copy --no-root-password`
> (The `initrdUnlock = false` partitions need to be manually opened if they participate in system eval.)

---

## Install NixOS remotely using `nixos-anywhere` {: #nixos-anywhere}

`nixos-anywhere` is my recommendad way to run installs.
The source machine needs to have nix, and will be probably running the build.
The target machine only needs to have ssh access.

`kayra` and `mergen` are live environments that have ssh access pre-configured,
so they are easy to target with other hosts in this flake.
But any target reachable via ssh should work.
First step is getting the system operational, as discussed in the [the previous section](#disko-install).

Steps are;

1. Boot into live environment, and connect to internet.
2. Prepare controller machine environment
3. Install remotely

### Boot into live environment and connect to network

Should be pretty straightforward for this step.
This is done on the host machine; this has to happen here.

### Source environment

These are needed on the source machine;

- Flake is up to date, and present.
- SSH access to the target machine must be available.
- Needed files to be dispatched (ssh keys, luks keyfiles) must be available.

### Install Remotely

Example command I issue is the following;

```
nixos-anywhere \
    --flake .#yertengri \
    --target-host kayra \
    --build-on auto
    --phases kexec.disko,install \
    --disko-mode disko \
    --no-disko-deps \
    --extra-files "_crypt/Systems/yertengri" \
    --chown '/home/ben-abuyah' '1000:100' \
    --chown '/home/wolframite' '1001:100' \
    --disk-encryption-keys "/tmp/Yertengri.key" "/tmp/Yertengri.key" \
    --disk-encryption-keys "/tmp/Yertengri_Linux.key" "_crypt/Systems/yertengri/etc/cryptsetup-keys.d/Yertengri_Linux.key" \
    --disk-encryption-keys "/tmp/Yertengri_Extra.key" "_crypt/Systems/yertengri/etc/cryptsetup-keys.d/Yertengri_Extra.key" \
    --disk-encryption-keys "/tmp/Yertengri_Swap.key" "_crypt/Systems/yertengri/etc/cryptsetup-keys.d/Yertengri_Swap.key" \
    --disk-encryption-keys "/tmp/Yertengri_Data.key" "_crypt/Systems/yertengri/etc/cryptsetup-keys.d/Yertengri_Data.key"

```

- `target-host` is the target machine's ssh address; if you can ssh with `ssh <address>` that's good.
- `extra-files` gets sent over, and ssh keys are needed for both host and user sops activation.
  They should have permissions set properly, otherwise it causes issues with activation.
- `disk-encryption-keys` are sent to the host machine for disko to run.
  Everything disko needs, it needs to be sent over and they need to be specified one by one.

> [!TIP]
> If disko already ran on the target machine, can change the flag to just `--disko-mode mount`

> [!TIP]
> `--build-on` flag can be tuned, doesn't need to be left at auto.
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

If applicable, following steps will onboard a user to use the computer;

- Log in to Mozilla Sync
