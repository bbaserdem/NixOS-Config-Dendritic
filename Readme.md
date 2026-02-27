# Nix Flake

My nix system flake.

- Uses flake-parts
- Follows dendritic pattern
- Using jj for vcs

# Development

- Each host gets their own named branch after hostname.
- Each host specific changes happens on their branch
- The main branch has development for all machines.
- Once development is stable, main branch is moved to the new change.
- Each host should be rebasing on the main branch before developing.
- Once host changes are stable, they should merge onto main.
