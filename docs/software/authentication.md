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
│       ├── ssh_age_host_ed25519_key
│       ├── ssh_age_host_ed25519_key.pub
│       ├── ssh_age_all_ed25519_key
│       └── ssh_age_all_ed25519_key.pub
└── ~/
    ├── .ssh/
    │   ├── id_ed25519
    │   ├── id_ed25519.pub
    │   └── config
    └── .local/auth
        ├── age/
        │   └── keys.txt
        └── ssh/
            ├── ssh_age_user_ed25519_key
            ├── ssh_age_user_ed25519_key.pub
            ├── ssh_age_all_ed25519_key
            ├── ssh_age_all_ed25519_key.pub
            ├── id_ed25519_<VCS-Provider>
            └── id_ed25519_<VCS-Provider>.pub
```

### Key Storage

SSH keys are kept on a LUKS encrypted storage hard drive.
The SSH keys for each host is kept under a directory `SSH/<hostname>`
This is made so that `nixos-anywhere` can point to one extra file to deploy.
This makes it so that `sops-nix` will work to deploy secrets immediately.

## SOPS

SOPS is mainly used with `sops-nix` to provision secrets using `nix`.
For this deployment, we use keys generated from ssh keys, as they are easier to deploy multiples of.

- Common user secrets
- Their own secrets
- Their host's secrets

Then for each config deployed;

- **NixOS**, **Darwin**: OS secrets decrypted from keys in `/etc/ssh/ssh_{host,all}_ed25519_key`
- **Home-Manager**: 

## GPG

## Passwords - KeepassXC
