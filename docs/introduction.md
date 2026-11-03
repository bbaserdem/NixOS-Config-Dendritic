# Introduction

This is documentation for my computers and systems in general.
Documentation includes this flake, how I use software etc.

## Todo List

### Current tasks

- Od ata syncronization
- Sync the new BOOX and get it working
- Reinstall su-ana
- Create and setup ben-abuyah
- QMK overhaul; redo and refresh
- Documentation of keyboards in system-docs
- Syncthing documentation redo and fix
- Picard config should be finalized, exported and shipped with flake
- For od-ata redo and recreate the vpn torrent container
- Stop video synching to yertengri (running out of space)
- Get mango and noctalia working and as a daily driver
  - noctalia for shell integration
  - wallet implementation for desktop-integrated secret management
  - kanshi for hotswap monitor management
  - integrate noctalia and power management for proper behavior
  - options for app launcher and menu
- Switch to firewalld across devices
- Deploy-rs for local one-hit update all computers workflow

### General task list

- Data organization for media directories
  - Organize documents and books
  - Organize pictures
  - Organize videos (-darr app stack)
  - Organize bookmarks
- Desktop
  - Declarative plasma
  - Declarative gnome
- Kayra
  - More compatible multi-usb setup
  - ARM solutions as well
  - Redo the environment with a bespoke `nixos` user.
  - Disable power saving on the gnome account; shouldn't blank or sleep on it's own.
  - Some unnecessary stuff needs cleanup; for example direnv should be removed.
  - Keys and the boot isos being on one machine not working; can't deploy keys and liveboot.
  - Split key usb into a different one with a good filesystem that supports ownership. (Forget about MacOS; we can do it bespoke.)
- MacOS alignment
  - Karabiner-Elements to make keybinds identical to linux
- Services
  - Home-assistant on od-ata
  - Firefly-iii on od-ata
  - paperless-ngx on od-ata
  - Jellyfin on od-ata
  - PiHole on raspberry pi
- Ricing
  - Splash static page for browser

### Deferred

- nix-droid for some management
- syncthing ignore files dispatch for nix-droid
- new den walks for homeManager class host
- den should create standalone outputs too
- Local llm server on yertengri
- Framebuffer-friendly setup

* Syncthing declerative restapi from secrets (waiting on upstream)

## Triage List

Record of where I have TODO in the flake that is not already covered above

- libfyaml broken on darwin; no zathura: `modules/hosts/su-ana/apps/docs.nix`
- Brew refuses cleanup w/out force `modules/systems/macos/homebrew.nix`
- primaryUser is to be deprecated; can remove this `modules/hosts/su-ana/user.nix`
- syncthingtray config module maybe? `modules/services/syncthing/syncthing.nix`
- move darwin settings from global to user based `modules/systems/macos/homebrew.nix`
- should become a module instead of bespoke `modules/hosts/su-ana/desktop/dock.nix`
- karabiner-elements module broken on nix-darwin `modules/applications/desktop/inputs.nix`
- xquartz broken on nixpkgs `modules/apps/utils/tools.nix`
- secretspec broken on nixpkgs-unstable `modules/devShells/workEdu.nix`
- liveiso usb incompat with deperecated boot.inirtd.systemd.enable=false `modules/hosts/kayra/configuration.nix`
- listenbrainz-mpd on darwin `modules/applications/audio/mpd/listenbrainz.nix`
- sidepulse; build dbus alternative
- secretspec config module is native in home-manager 26.11 `modules/applications/development/secretspec.nix`
- opencode2 config migration `modules/applications/development/ai-tools/opencode.nix`
- pi config, also inline module in 26.11 `modules/applications/development/ai-tools/pi.nix`
- figure fonts, theme and kitty `modules/applications/tools/terminals/kitty.nix`
- neovim config, catpaq and mason as alternative `modules/applications/development/neovim`
- direnv broken on darwin? `modules/applications/shell/direnv`
- runapp under wayland compositors with uwsm
