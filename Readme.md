# Nix Flake

My nix system flake.

- Uses flake-parts
- Follows dendritic pattern
- Using jj for vcs

# Todo

- [ ] Clean and setup secrets (user: beets)
- [ ] Integrate stylix properly (user: kitty)
- [ ] Import other home-manager configuration (URGENT: PNPM)
- [ ] Neovim dark/light mode auto-detect
- [ ] Fix darwin UID issues (user: factory)
- [ ] Darwin stable doesn't have shell integration options in 25.11
- [ ] Neovim: setup localleader commands to render markdown.
- [ ] Configure syncthing (import .stignore files to be managed by nix)
- [ ] Finish personalized claude config
- [ ] Add codecompanion to nvim wrapper
- [ ] Setup individual theming for each host
- [ ] Test if kitty theme importer is working
- [ ] Now that we moved from brew to nix for GUI, fix dock in darwin.
- [ ] Test darwin modules on macos
- [ ] Configure joey's user
- [ ] Import desktop, display manager config
- [ ] Import grub config
- [ ] Fix polkit issues in hyprland
- [ ] Test nixos modules on laptop

# Development

- Each host gets their own named branch after hostname.
- Each host specific changes happens on their branch
- The main branch has development for all machines.
- Once development is stable, main branch is moved to the new change.
- Each host should be rebasing on the main branch before developing.
- Once host changes are stable, they should merge onto main.
