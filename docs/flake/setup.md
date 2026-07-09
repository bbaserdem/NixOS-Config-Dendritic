# Flake Setup

Usage inside this flake.

---

## Flake-Parts

Main scaffold for this flake is `flake-parts`.

- _modules_ is where flake-parts modules live.
- Any module here is imported by [import-tree](TODO: link)
- Flake inputs are auto-generated from `config.flake-inputs` by [flake-inputs](TODO: link).
- Flake-wide metadata is stored in `localConfig`.

---

## Packages

`packages` directory contains custom packages exported by this flake.
Arguments to `TODO: what is this exactly?` are to be the files.
We use [pkgs-for-flake-parts](TODO: url) to auto export packages.

---

## Den

For system topology, [den](https://den.denful.dev/) is used.

---

## Devshells

DevShell's are provided by this flake.
For programming projects; this is meant to serve devshells for development.

Keeping dev shells central helps with deduplication of packages across devshells.
Working with other people also becomes more convenient,
repos don't need to have nix files in them, reducing friction.
(This workflow works with untracked .envrc to initialize the devshells.)

Downside is, it's hard to get direnv to realize upstream changes in devShells if they are remote.
Either file reference to the local instance is used;
or use these commands to force a refresh;

```
nix develop --refresh github:bbaserdem/NixOS-Config-Dendritic#default
nix develop --refresh --option tarball-ttl 0 github:bbaserdem/NixOS-Config-Dendritic#default -c true
```

---

## Templates

Templates are provided by this flake.
Could be for anything, for now contains starter templates for coding projects.
These are prefixed with an underscore to prevent potential nix files from being loaded by this flake.
Since .gitignore files in templates might ignore other files, all files here have to be force-added to vcs.

---

# History

A historical account of how this flake evolved.

This system documentation is a culmination of me using Linux for my computers.

## Archlinux Era

I used to use Archlinux; but was often frustrated by having to take notes
of my full installation procedure, and how I configured my system.
It became untractable; because I would tackle an issue (let's say DNS resolution
at my research lab) and somehow it would be solved; but then I would switch
to a new PC or reinstalled my computer and nothing would stay the same.
Also, having multiple computers, setting up the same stuff many times became
very annoying.

I tried to solve this problem by creating my own package repository,
and using [meta packages](https://disconnected.systems/blog/archlinux-repo-in-aws-bucket/)
to do system administration.

The whole pipeline was bootstrapped by my bash scripts, and while it worked
it was always fragile. But having this management really alleviate this issue.

## NixOS Switch

I have heard of NixOS before and I only knew it had to do something about
software having their own specfic dependencies packaged so that you don't have
issues with mismatched `gcc` versions in a system.

Did not seem relevant until the concept of _declerative_ system management
entered my radar, and I discovered over time that NixOS is doing exactly
what I have been attempting with arch.

I thought I can handle a steep learning curve, but I was wrong.
I spent many hours trying to figure out what exactly `home-manager` was doing
and what's the difference between `home-manager` and `nixos`.

While procrastinating writing my dissertation, I decided to migrate my OS.
I took the advice of someone else, (very lucky) whose advice sounded like the
advice I give to people about switching to a new keyboard layout.

> Do not change the environment you depend on.
> Change on your own, non critical time.
> Only switch when you are adjusted to the new stuff completely.

In keyboard layouts, this advice culminated to me only changing my phone
keyboard to dvorak; and only after finishing touch typing lessons and being
comfortable typing on a keyboard do I pull the trigger and do keyboard switch.
For OSes, this meant that I wanted to replicate my entire OS in a VM first,
then when I have a few days downtime migrate to NixOS on bare metal using the VM config.

It took me two months to translate all my dotfiles and configuration to nix.
But I was successful without downtime; and I attribute my learning success to\
that redditor who directed me in the correct path.

## First Flake

My first configuration was not unguided.
I followed [Misterio77's starter flake](https://github.com/Misterio77/nix-starter-configs).
That's my old flake, and it served me well for a long time.
Through trial and error, I learned how nix language works;
along with the functional programming paradigm; and built my own
topology generation bootstrap that auto-generated configurations.

## Flake-Parts and Dendritic Pattern

I've been hearing about the dendritic pattern for a while now.
I first scoffed at it, because from my understanding I was doing the same thing.

It didn't click to me why `flake-parts` was being used at first.
Mentally, the nixos module ecosystem was so divorced from the flakes'
underlying nix fundamental code that I failed to see what it provided.

After a while of trying to figure out from reading multiple resources,
things started clicking a little bit piece by piece.

Flake-parts lets a flake, doesn't have to be a system configuration flake,
use the module system everywhere.
Just like how different nixos modules can all import each other and get recursively
merged, and transform the output towards a fix point while also reading from that
output; flake-parts allows that to be done on the entire flake.
Doesn't sound very transformative at first, but it is actually such a non-trivial
structure on top of flakes, but it's so INCREDIBLY USEFUL.
Being able to treat the flake _output_ as a final evalutation,
dispatch behavior to the transformation pipeline from one unified interface,
which is battle tested in the nixos ecosystem. Just chef's kiss.

Then learned about the dendritic pattern, which heavily uses the functionality
of flake-parts, but is not necessarily dependent on it.
Which is what I was essentially trying to reach by myself.
Dendritic pattern conceptually divides a configuration into it's atoms,
and formulates each configuration output as a collection of the sharable atoms.
Which is also incredibly useful, and I would know because I was trying to do this;
just through hand rolled nix code machinery.

## Den

I ran across `den` after finding useful flake-parts extension modules,
such as _import-tree_ and _pkgs-for-flake-parts_ and _flake-file_ etc.

I checked it out, and I did not understand anything about it,
what it was used for, and why is it so hard to understand.
I scoffed at it, and turned away as "just some random stuff that's unneeded complexity".
I was also offput by the `CLAUDE.md` because I have a distaste for Anthropic products,
and (ironacally since I am an AI Software Engineer now) AI assisted code.

I have been hitting pain points in my dendritic flake with flake-parts.
Basically, I have been having a hard time issuing information into my system
configuration that sometimes needs to be cross cutting; and infinite-recursions
where I know there shouldn't really be a recursion. (Because my mental model
knows where the source of truth is; but nixos doesn't because it's not my head.)

That's where I started creating this option `localConfig` to store my _topology_
information in a first level eval done on flake level, which then can inject
as a single source to each host configuration.

Hand rolling this has been very finnicky, and trying to be consistent
with the application required a lot of attention. I kept conceptually thinking
about den, even though I did not understand what it is.
Not to mention doing my syncthing dispatch has been an absolute _nightmare_.

After taking a hint from my past; where I keep scoffing at a solution to my woes
because I try to handroll it myself in a subpar fashion, but end up surrendering
to it eventually, I decided to learn what den is.

It took me a while to realize that den does not magically solve every problem I have.
It's a framework to build the topology of system configurations.
It doesn't replace flake-parts, or does away with the dendritic pattern.
It's more like a _new_ module system for describing the topology of the **fleet** of hosts;
and codify the construction of flake outputs.
