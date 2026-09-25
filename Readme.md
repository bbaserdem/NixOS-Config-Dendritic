# System Configuration Flake

My nix flake used to configure my computer systems.

## Documentation

All information on what this flake provides/does is available in [`docs/`](./docs).

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
