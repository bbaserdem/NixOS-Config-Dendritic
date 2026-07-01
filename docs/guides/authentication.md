# Authentication

Various encryption and authentication methods I employ, their usage is documented here.

A global implementation I use is that I have a USB flash drive with a `gocryptfs`
vault that holds backup keys.

The filetree in the USB looks like the following;

```
/
├── etc/
│   ├── ssh/
│   │   ├── ssh_host_ed25519_key
│   │   └── ssh_host_ed25519_key.pub
│   └── cryptsetup-keys.d/
│       └── <HostName>_<PartLabel>.key
└── ~/
    ├── .ssh/
    │   ├── id_ed25519
    │   ├── id_ed25519.pub
    │   ├── id_ed25519_<VCS-Provider>
    │   ├── id_ed25519_<VCS-Provider>.pub
    │   ├── ...
    │   └── config
    └── .config/sops/age
            └── keys.txt
```



## TODO

- [ ] GPG keys setup
- [ ] LUKS layout



---

## SOPS

SOPS is used with `sops-nix` to provision secrets using `nix`.

> ![WARNING]
> sops-nix nixos module can use two backends for secrets deployment.
> Can use an activation script which happens during Stage 2 (initrd)
> and runs before Stage 3 (system given over to systemd).
> It can also use a systemd unit (`sops.useSystemdActivation = true;`)
> but this means that secrets are decrypted during Stage 3.
> Unlocking containers happens in stage 2; which means that using the systemd
> deployment cannot be used to deploy LUKS keyfiles.
> (Not even through the /etc/cryptsetup-keys.d path since the secret symlinks
> targets don't exist yet.)
>
> The systemd version is thus switched off, but it auto-enables if
> either sysusers or userborn is enabled.
> We may need to employ different unlock methods for LUKS independent of SOPS.
> Either put the keyfile raw in cryptsetup-keys.d or use cached passwords.

### Keys Setup

There are two locations needed; one for darwin/nixos activation, and one for home-manager.
When these files exist on the filesystem, sops activation succeeds.

For host level secrets, the `SSH` backend is used.
The canonical host ssh key location is used; `/etc/ssh/ssh_host_ed25519_key`.
These secrets are meant to be host-specific.

For each user, we have two **age** keys in `~/.config/sops/age/keys.txt`.

- Their own age key. (Pure age)
- The specific host's *derived* age key, from `/etc/ssh/ssh_host_ed25519_key`.
(So that we can edit secrets to a specific host.)

These keys are dispatched during [deployment](./deployment.md).
In the vault, the `Keys/<hostname>` folder mimics the full filesystem layout.

There is also a global GPG key (kept on a [yubikey](#yubikey))
that can be used for SOPS decryption.

### SOPS usage

General usage is simple; `sops` reads keys from the canonical location;
which is `~/.config/sops/age/keys.txt` and uses keys there to decrypt files.

For text files, it's enough to edit them with the `sops <file>` command.

For binary files; use sops directly to produce a binary file;

```
sops -e <filepath> > <destination>.bin
```



---

## SSH

SSH access to various host and services.

Command to generate key is;

```
ssh-keygen -t ed25519 -N "" -f /path/to/key
```

### Providers

TODO: Figure out how ssh-agent works

### Host Access

In order to access certain hosts on the local network,
some cross-host ssh keys are dispatched with `sops-nix`.
This allows things such as remote deployment.



---

## LUKS

For LUKS, `sops-nix` dispatches key files needed to boot at boot time.
The proper files get decrypted, and exposed in the `/run/cryptsetup-keys.d/<container>.key`.

The same files could be created at `/etc` but creating them in `/run` is safer by generation on tmpfs.
Besides that, disk generation (`disko`) should handle creating the LUKS containers.

### Container setup

> TODO: Document this

The way a LUKS partition is set up is; there will always be a passphrase.
There will always also be a keyfile, generated with random bytes.

```
dd bs=512 count=4 if=/dev/random iflag=fullblock of=<container>.key
```


---

## GPG

I have one GPG key.
The GPG setup involves a master key, then 3 subkeys.
This key is kept on a YubiKey drive.

### GPG Agent

> TODO: Figure out GPG agent backend/setup

### Setup

`assets/public.asc` is available in this repo, and dispatched to users' configs.
That's the public GPG key block, safe to share.

To mark the key as FIDO supplied though, there needs to be a registry;

```
# Import public key
gpg --import <flake>/assets/public.asc
# Make the card learn the key
gpg --card-status
# Set trust to ultimate
gpg --edit-key <FINGERPRINT>
trust
5
y
save
```

### GPG Key Generation

The process to generate the keys is documented here.

(It's nice to create an empty GPG home to avoid confusion, but not necessary.)
The generation workflow is the following;

```
# Prepare environment
export GPG_TTY="$(tty)"
export GNUPGHOME="<some-directory>"
mkdir -p $GNUPGHOME

# Generate this key
gpg --pinentry-mode=loopback --expert --full-generate-key
# Pick ECC (set your own capabilities)
# Toggle capabilities until only certify remains
# Select Curve 25519; the most modern one as of today
# Choose expiry date if wanted
# Enter real name and email
# Enter the passphrase

# You should get a fingerprint now
export KEY_FPR="<Fingerprint>"

# Enter the edit menu, and generate the subkeys
gpg --pinentry-mode=loopback --expert --edit-key $KEY_FPR
# addkey, ECC (sign only), Curve 25519, 1y
# addkey, ECC (encrypt only), Curve 25519, 1y
# addkey, ECC (authenticate only from edit menu), Curve 25519, 1y
# save

# There should be 4 keys here;
gpg --list-secret-keys --with-subkey-fingerprints --keyid-format long $KEY_FPR
```

#### Backup

Before doing any YubiKey operations, the keys should be backed up to offline media.

```
export BACKUP_DIR="<backup-dir>"
mkdir -p BACKUP_DIR

# Export public key
gpg --armor --export $KEY_FPR > $BACKUP_DIR/public.asc
gpg --pinentry-mode=loopback --armor --export-secret-keys $KEY_FPR > $BACKUP_DIR/secret-master-and-subkeys.asc
gpg --pinentry-mode=loopback --armor --export-secret-subkeys $KEY_FPR > $BACKUP_DIR/subkeys.asc
gpg --export-ownertrust > $BACKUP_DIR/ownertrust.txt
gpg --pinentry-mode=loopback --output $BACKUP_DIR/revoke.asc --gen-revoke $KEY_FPR
```

Then these files can be used to recover and/or reuse

```
gpg --import public.asc
gpg --import secret-subkeys.asc
gpg --import-ownertrust ownertrust.txt
```

#### YubiKey

First, if it's first time using YubiKey, set it up

```
gpg --pinentry-mode=loopback --card-edit
admin
passwd
# Default passwords are; admin 12345678 and user 12345
# Regular pin change asks for regular passwd
# Admin pin change asks for admin passwd (has some more text in the prompt with device ID)
```

Then with the YubiKey plugged in, transfer the subkeys


```
gpg --pinentry-mode=loopbock --edit-key $KEY_FPR
key
# Should show the CSEA keys
# 1 is the signing subkey, select and send (check for asterisk)
# It will first ask for gpg key passphrase, then the admin password for the yubikey
key <A> # Select the S subkey
keytocard 
1 # 1 is the signature slot
key <A> # Deselect the S subkey
key <B> # Select the E subkey
keytocard
2 # 2 is the encryption slot
key <B>
key <C> # Select the A subkey
keytocard
3 # 3 is the authentication slot
save

# To verify, keys will be on the card and the subkeys will have ssb> prefix
gpg --card-status
gpg --list-secret-keys --with-keygrip $KEY_FPR
#
```

This should upload the keys, to check the keys;

```
gpg --card-status
gpg --card-edit
fetch
quit
gpg --list-secret-keys
```


---

## KeepassXC

For password management, `kbdx` vaults with `keepassxc` is used across computers.

> TODO: Setup key management organization and complete this.
