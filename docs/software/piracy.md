# Torrenting

We use torrenting to download large files off the internet.

Torrenting principles are;

- Containerized and confined to VPN network.
- Interface should be available on the local network.

## Stack

- `qbittorrent-nox` as torrent client.
- `nixos-container` as containerization.
- `mullvad` as VPN provider
- `nginx` for reverse proxy web

Chose `qbittorrent` due to good integration with media tagging tools.
`qbittorrent-nox` can run headless, and exposes a web UI.
As a side effect; we don't have a GUI app to hook up to the client, should be fine.
Web UI is available at `torrent.local` in the local LAN.

`nixos-container` for easily declare the container in nixos.
No need for docker, or heavier VMs for this.
Could even be promoted to an rp in the future since it's basically a conatiner from a `nixosConfiguration`.

`mullvad` because of vendor lock-in.

> TODO: Add mullvad secret

> ![IMPORTANT]
> Mullvad apparently removed port forwarding support in 2023
> Which might be an issue with private trackers for seed ratios.
> Might want to switch to AirVPN

Rest of the network stack is shared.

## Setup

Container runs on the homelab.
Only network allowed is through VPN and `host<->container`. (Kill-switch)
Host advertises `torrent.local`, and routes it to the container.

> TODO: Filesystem layout
