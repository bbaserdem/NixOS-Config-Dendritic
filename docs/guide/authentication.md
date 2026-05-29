# Authentication

Various authentication methods across many tools, their usage is displayed here.

## TODO

- [ ] GPG keys setup
- [ ] LUKS layout

## SSH

Command to generate key;

```
ssh-keygen -t ed25519 -N "" -f /path/to/key
```

### Layout

Authentication files exist on multiple different directories.
A rundown is as following

```
/
├── etc/
│   └── ssh/
│       ├── ssh_host_ed25519_key
│       └── ssh_host_ed25519_key.pub
└── ~/
    ├── .ssh/
    │   ├── id_ed25519
    │   ├── id_ed25519.pub
    │   ├── id_ed25519_<VCS-Provider>
    │   ├── id_ed25519_<VCS-Provider>.pub
    │   ├── ...
    │   └── config
    └── .config/sops/age
            └── keys.txt                # Age key for specific user: sops-nix
```

### Key Storage

SSH keys are kept on a LUKS encrypted storage hard drive.
The SSH keys for each host is kept under a directory `SSH/<hostname>`
This is made so that `nixos-anywhere` can point to one extra file to deploy.
This makes it so that `sops-nix` will work to deploy secrets immediately.

## SOPS

SOPS is mainly used with `sops-nix` to provision secrets using `nix`.
Each user will have two keys in `~/.config/sops/age/keys.txt`;

- Their own age key
- Their host's derived age key from `/etc/ssh/ssh_host_ed25519_key`.

## GPG

The GPG setup involves a master key, then 3 subkeys.
This key is kept on a YubiKey drive.

### Generation

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

### Backup

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


### YubiKey

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

## Passwords - KeepassXC
