# Syncthing

Syncthing setup across all using computers.

My syncthing setup is meant to be used across different hosts and computers.

## TODO

- [*] dataDir = "/home/syncthing"
- [ ] redo secret hierarchy to `syncthing/host{,-user}/{key,cert,restapi}`
- [ ] ACL rules
- [ ] Paperless synching only media dir (ACL rules as well)
- [ ] Paperless timer to backup db

## Context

Using nix, syncthing can be configured in two ways; as a `home-manager` or `nixos` module.
`nix-darwin` does not have a syncthing module; but `home-manager` module does integrate with launchd.
Due to this, the design choice was to use system-wide syncthing in nixos, and user based syncthing in darwin.

Our current secret provisioning system provisions one key/cert per host right now.
So it is not compatible with multiple user Darwin and Standalone HM.
(Potentially can fix this, along with port config.)

### `inputs.self.modules.generic.syncthing`

This module can be loaded both into `nixos` and `home-manager` context.
For the programs module, it configures settings compatible between the two.

This module is written to in user configuration folder as well.
Shared folders, and which hosts they are shared on, is defined by the users.
That way, while each nixos host has one instance of syncthing, users can define their own folders

### `inputs.self.modules.homeManager.syncthing`

This module is meant to be loaded for `home-manager` context.
In linux, this enables the tray icon for each user.

There is plans to also configure the tray icon to use the REST api key automatically;
but neither is `syncthingtray` configuration from `home-manager` is supported,
nor is setting the REST api key from a secret file supported in nixos.
When this REST api key is supported, however, this key will be defined as a host-level secret.
This home-manager module also imports this secret into the userspace.
Users must be in the `syncthing` group to be able to get these secrets.

### `inputs.self.modules.nixos.syncthing`

This module enables the system wide syncthing process, pulled by the generic module.
It runs on system level, and runs as it's own user.
The target folder for syncthing is `/home/syncthing`
allowing large media files to live on their own hard drive.

Access to different directories will be provisioned usinc ACL.
This, along with other restrictions, makes it so that file ownership cannot be (and generally shouldn't) synced.

This module also enables relay, since this is Linux only feature.

### `inputs.self.modules.darwin.syncthing`

Darwin itself does not have a syncthing module.
Therefore, the darwin module provisions the generic module on all home-manager users.
This restricts the darwin configurations to a single user,
syncthing with the same configuration running on multiple users simultaneosly will be erroneous.

Syncthing keys are host-level information, so their secrets are defined on darwin level.
The darwin module also provisions the darwin sops secrets to the syncthing configuration of all users.

## Folder Layout

We envision the following folders for syncthing;

- `Documents-<user>`: `~/Documents` symlinks here
- `Downloads-<user>`: `~/Downloads` symlinks here
- `Videos-<user>`: `~/Videos` (~/Movies in Darwin) symlinks here
- `Music-<user>`: `~/Music` symlinks here
- `Pictures-<user>`: `~/Pictures` symlinks here
- `Paperless`: The file database that paperless uses

## Usage

While nixos module supports `.stignore` files, home-manager doesn't.
Host specific behavior is also not easy to configure this way.
We have a `Stignore` folder in each directory, that contains various `Stignore` files.

- Folders should be defined to `generic.syncthing` module, *except* their path variable.
- **IMPORTANT**: All folders should have `ignorePerms = true`` set
- All folders should have their enable flags set to `lib.mkOptionDefault false`.

### Host Config

**NixOS**

Import `nixos.syncthing` module to `nixos.<host>`
Define secrets `sops.secrets."syncthing/{cert,key,restapi}"` to `nixos.<host>` module.
Define public machine info `services.syncthing.settings.devices.<host>` to `generic.syncthing` module.

**Darwin**

Import `darwin.syncthing` module to `darwin.<host>`
Define secrets `sops.secrets."syncthing/{cert,key,restapi}"` to `darwin.<host>` module.
Define public machine info `services.syncthing.settings.devices.<host>` to `generic.syncthing` module.

**Home Manager Standalone**

Import `generic.syncthing` module to `homeManager.<host>`
Define secrets `sops.secrets."syncthing/{cert,key,restapi}"` to `homeManager.<host>` module.
Define public machine info `services.syncthing.settings.devices.<host>` to `generic.syncthing` module.

### User Config

Folder *paths* should be defined to;
- `nixos.syncthing` module, as `~/<Folder>-<user>`
- `homeManager.<user>` module, as `~/<Folder>` (Mutate Videos to Movies for `pkgs.stdenv.hostPlatform.isDarwin`)

Folder *enable flags* should;
- Be set to `lib.mkDefault true` in `nixos.<user>`
- Be set to `lib.mkDefault true` in `homeManager.<user>`

Symlinks for each user should be defined as an *anonymous module* to the `home-manager.users.<user>.imports` list in the `nixos.<user>` module.
(Symlink are only needed in NixOS, if the user is in nixos and managed with hm-as-nixos-module.)

### Result

These should cause the following behavior;

**Nixos**

Folders in shared `/home/syncthing` location.
Symlinks from user home to syncthing folders. (From the module passed to `home-manager.users.<user>.imports` from `nixos.<user>`)
Access is granted with ACL; so ownership being mixed syncthing/user is not a problem.
Only syncs users that are enabled on this host. (`nixos.<user>` sets enable flag.)
The extra folder settings in `home-manager` for users doesn't matter, because no enable entry point in there.

**Darwin**

Folders on `/Users/user` location.
Only sync users' folders. (Service is in `home-manager`, enable flags from users' `home-manager`.)
Service is `home-manager`, ownership not a problem.

**Home Manager Standalone**

Folders on `/home/user` location.
Only sync users' folders. (Enable flags are from users' `home-manager`)
Ownership not an issue from `home-manager`.

### Keys

To generate keys;

```bash
export OUTPUT_DIR="/tmp/syncthing-keys"
nix run nixpkgs#syncthing -- generate --home "$OUTPUT_DIR"
nix run nixpkgs#syncthing -- device-id --home "$OUTPUT_DIR" > "$OUTPUT_DIR/public.id"
nix run nixpkgs#openssl -- rand -hex 16 | fold -w4 | paste -sd'-' - > "$OUTPUT_DIR/restapi.key"
```
