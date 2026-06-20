# Deployment

Guide into deploying the system configuration flake to different machines.

## NixOS Installation

Installing NixOS on various machines.

### Local Installation (disko-install)

The first item is to use `Kayra`; the live USB, to boot into this computer.
As of now, `Kayra` is a live-iso, output into the package outputs.
We are using `MultiOS-USB` to boot this system.

TODO: Change Kayra from liveiso to an on ramdisk but local to usb installation.
Right now, MultiOS-USB support (needs scripted boot by /boot/grub/loopback.cfg)
is deprecated; and unknown whether Ventoy can deal with this either.
Switching to an impermanent setup where the OS is kept on the usb,
and loaded into RAM would be a more maintainable (and secret deployable) solution.
This would also enable LUKS encryption, so we could deploy secrets here as well.

1) Boot into live environment.
2) Connect to internet, sync the flake and change to the directory.
```
# This command should exist in the live environment
flake-sync
# CD to flake directory
cd-flake
```
3) Mount the key-vault from USB;
```
udisksctl mount --block-device=/dev/<usb-device>
mkdir _crypt
gocryptfs /run/media/sbp/<Device>/KeyVault _crypt
```
The USB has a key vault with gocryptfs.
In the vault, there should be a `Systems` and `LUKS` directory.
**Assumption**: 
4) Sync the flake; the user should have a flake-sync command in the shell.
5) Confirm the disk exists, and aligned with disko setup.
6) Put the LUKS key files in `/tmp`, and create a passphrase file `/tmp/<HostName>.key`.
Disko expects them in the specific locations
7) *Optional,* ***DESTRUCTIVE***; test out whether disko works with the following;
```
disko --mode disko --flake .#<hostname>
```
8) Run the `disko-install` command. (There is a `--dry-run` flag to )
```
# Need to provide the disk argument multiple times for each disk!
sudo disko-install \
  --flake .#<hostname> \
  --extra-files _crypt/Systems/<hostname>
  --disk Linux /dev/...
```

### Remote Installation (nixos-anywhere)

TODO: Do this part

## Darwin

TODO: Do this part
