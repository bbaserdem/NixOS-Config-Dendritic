# Paperless

`paperless-ngx` is a document management system.

## TODO

- [ ] Figure out port workflow
- [ ] Figure out injestion folder symlinks
- [ ] Metadata backup timer

## Features

The proposed way of using paperless has the following features;

- Use `syncthing` for documents, media and DB backup.
- Provide a networking endpoint to send documents in for ingestion.
- Expose in the local network a web UI.

## Module

The paperless module found in `modules/apps/services/paperless` is composed of the following parts.

### `paperless.nix`

Main paperless configuration entry

- Creates the module `modules.nixos.paperless`.
- Enables paperless.
- Sets up directories, provisions permissions etc.
- Periodic DB backups.

### `keys.nix`

Authentication related settings

- Conditional on `sops-nix` and existing keys.
- Sets up secrets used to access the web ui.

### `network.nix`

Networking related

- Sets up network shared ingestion directory, conditional on samba.
- Sets local network DNS to resolve to the web ui.

### `users.nix`

Factory function for users to integrate with running paperless instance.

- If `paperless-ngx` is enabled on the system, sets up links and permissions to ingestion folders.
- Sets up local network ingestion shares.

### `sync.nix`

Settings for syncthing for document synching.

- Conditional on `syncthing` being enabled.
- Sets up the folder options, ACL and permission access.
- Sets up sync rules conditional on whether `paperless-ngx` is enabled on parent system or not.
