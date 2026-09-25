# Introduction

This is documentation for my computers and systems in general.
Documentation includes this flake, how I use software etc.

## Todo List

- [ ] Full den migration
  - [ ] Finish exporting `apps/` modules.
  - [ ] Regularize den layout and usage across modules
  - [ ] Revisit environment variable dispatch; try to make it host-specific too
        (API keys in environment shouldn't really come from sops-nix; other methods!)
  - [ ] Switch `yel-ana` to den
  - [ ] Reinstall `su-ana` with den management
  - [ ] Install `od-ata` and `yertengri`
  - [ ] Set up new walks for `homeManager` class hosts, and standalone outputs.
  - [ ] Reorganize syncthing aspect so that certain behavior is isolated.
        (Mainly thinking about using nix-droid + home-manager to dispatch stignore;
        but not run syncthing.)
- [ ] New hardware
  - [ ] Better GPU goes in yertengri.
  - [ ] Document, name, and see what I can do with the new BOOX.
  - [ ] Redo qmk, integrate user overlay to flake maybe
  - [ ] Document keyboards
  - [ ] Monitor alignment as metadata; should be consumable through den
- [ ] MacOS alignment
  - [ ] Virtualizing mac native on mac to containerize work
  - [ ] Karabiner-Elements to make keybinds identical to linux
- [ ] Set up data organization
  - [ ] Codify media management guidelines in docs
  - [ ] Align syncthing with the guidelines
  - [ ] Organize actual data in the format
  - [ ] Picard config output
- [ ] Organize `nix-droid`
  - [ ] Define usecases and what's needed
  - [ ] Write den machinery for android
  - [ ] Deploy to erlik
- [ ] New software
  - [ ] Either configure, or retire, aria download manager for firefox
  - [ ] Migrate passwords from pass to keepassxc
  - [ ] Nixos container for vpn locked torrent server
  - [ ] Paperless-ngx server on local network
  - [ ] Firefly-iii server on local network
  - [ ] Set up live usb setup.
  - [ ] Set up picture organization workflow
  - [ ] Set up video organization
  - [ ] Set up internet organization (bookmarks etc)
  - [ ] Set up plasma declerative management
  - [ ] Set up gnome declerative management
- [ ] Networking
  - [ ] Set up pihole for `od-ata` or the rp5.
  - [ ] Set up firewalld
  - [ ] Local network with services
  - [ ] Set up `deploy-rs` for flake deployment across network
- [ ] Ricing
  - [ ] Abandon hyprland, move to niri or some other wayland compositor
  - [ ] Re-configure noctalia shell; consider other options
  - [ ] Harden environments to be frame-buffer friendly?

Things delayed until upstream adoption that I won't manually do right now

- [ ] Firefox old vs new profile management
- [ ] Syncthing declerative restapi from secrets

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
