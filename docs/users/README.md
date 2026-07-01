# Users

General user setup for these computers.

In the flake, user related setups are in the `modules/users` directory.
Besides personal configurations, common features are setup here.


---

## User Paths

Syncthing is heavily used for file syncing in my personal computers.
And it's coupled with **XDG desktop specification**.
`modules/users/xdg-paths.nix` provides the implementation from `localConfig`.

All my personal computers follow a similar workflow.
The `/home` path is a seperate partition meant to hold large data.
Actual `/home/<user>` is a btrfs subvolume on the main OS partition.
XDG desktop paths are bind mounts to `/home/syncthing/<User>/<xdg-name>`;
This layout keeps runtime and user files on the btrfs partition
(usually a faster nvme) and media like data in an ext4 partition.


## Environment Variables from SOPS

`modules/users/sops-env.nix` is an implementation that lets user profiles
load envirornment variables.


## User Profile Pictures

`modules/users/user-icon.nix` dispatches profile pictures for users from SOPS secrets.
Since these are meant to be unlocked for *nixos* configurations,
they are dispatched to the root share directory instead of user secret directory.
Each host can override with their own variant too.

These files are also dispatched to `nix-darwin` configurations as well;
but imperatively.
