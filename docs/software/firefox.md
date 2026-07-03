# Firefox

Firefox is the browser of choice.

The reason for this choice is the super extensibility with `home-manager`.

## Setup

The firefox module is customized, and reads from `localConfig` to build firefox config.

## Profiles

Due to firefox having two profile implementations; there is a bit of complications.

- The _old_ profile implementation, interfaces `home-manager`
- The _new_ profile implementation, firefox stores this is a mutable sqlite db.

I submitted a [home-manager PR](github.com/nix-community/home-manager/pull/9590) as first step.

Need to figure out how to do the migration too.
