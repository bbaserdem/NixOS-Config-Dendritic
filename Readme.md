# System Configuration Flake

My nix flake used to configure my computer systems.

## Design

- Uses flake-parts
- Follows dendritic pattern
- Using jujutsu for vcs

## Todo

- [ ] Neovim: setup localleader commands to render markdown.
- [ ] Hyprland: migrate to lua
- [ ] Configure joey's user
- [ ] Fix polkit issues in hyprland
- [ ] Test nixos modules on laptop
- [ ] Remove nofail mount options after confirming mounts etc. work
- [ ] Redo beets library organization

## Development

WIP; the guidelines have not been followed, but hoping to adopt soon.

- Each host gets their own named branch after hostname.
- Each host specific changes happens on their branch
- The main branch has development for all machines.
- Once development is stable, main branch is moved to the new change.
- Each host should be rebasing on the main branch before developing.
- Once host changes are stable, they should merge onto main.

## AI Disclaimer

I maintain that this repo does not contain any code written by AI.
I do, however, use AI tools for design discussions, debugging and research.
This does include copying code blocks from chats, but AI is not allowed to do any direct edits.
