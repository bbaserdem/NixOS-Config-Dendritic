# Dendritic Flake

The main design of this flake is the dendritic pattern.
The design concepts are followed across different frameworks,
and I try to align with external terminology as much as possible.
The concepts used are the following;

- **Features**: Conceptial container for a functionality.
  This is akin to, but not limited to, a software.
  A feature can materialize across different _entities_.
  Features are characterized by their name; referred to as `<feature>`.
- **Aspects**: An implementation abstraction for a feature.
  (Comes from the same _aspect_ concept in `den`.)
  Most cases, this is the same as a _feature_, mostly interchangeable.
  But the difference is; a _feature_ is a conceptual container,
  an _aspect_ is a unit contained under that feature.
  Sometimes, a feature may contain different aspects.
  An example would be a feature that is a single server and multiple client services.
  It's one _feature_ as in it's in one conceptual container.
  However, there can be two _aspects_ to this;
  a `feature-server` _aspect_ that serves this _feature_,
  and a `feature-client` _aspect_ that allows using the served _feature_.
- **Contexts**: Different situations that an _aspect_ can manifest in.
  This corresponds to _entity kinds_ in `den`, and realized as _modules_
  for a `flake-parts` _class_ (_module_ evaluation domain; canonically
  `nixos`, `darwin`, `homeManager`)

So, in summation, a _feature_ is one, or many, _aspects_,
which for each _context_ expose a `flake-parts module` or equivalent.

### Categories

I personally organized my _features_ into several **types**.

- **Systems**: Flake output types; mostly configurations output by this flake.
  Unlike _entity kind_ this is more a concept; such as standard _MacOS_ desktop,
  A _NixOS_ desktop, _liveusb_, _Raspberry Pi_ etc.
- **Frameworks**: Programs that provide systems with broad range of capabilities.
  Such as _disko_, _sops_ etc.
- **Applications**: Programs that can be setup for one on one interactive use.
  User facing apps, such as _mpd_, _obsidian_ etc.
  Applications have `domains` such as _documents_, _music_ etc.
- **Utilities**: Not exactly programs, but more like runners and processes.
  Things such as _networkmanager_, _avahi_, _syncthing_ etc.
- **Services**: Programs that are _serving_ functions, not just direct point of contact.
  Things such as _paperless_ etc.

---

## Flake-Parts

Usage of `flake-parts` in this flake.

### Modules

Modules are kept as vanilla `flake-parts` modules as much as possible in this flake.
As long as a module is not den architecture dependent; it is made into a
flake-parts module.

Since dispatch pipeline is complex, for module deduplication nix convention
supports the top-level `key` argument.
Usually; in regular nix; this argument is auto-populated with a hash based on the
file apparently.

To be explicity, I try to define key manually; with `<module-name>#<module-class>`
as much as possible.

> [!NOTE]
> I imagine there might be den-context dependent modules that might need to
> be in several different places; for these I do support inlining context
> arguments as module argumnets, and writing these as flake-parts modules.

---

## Den

How is den used in this flake.

In general, I try to keep configuration in `flake-parts` modules as much as possible.
Den managed the generation pipeline, and just imports `flake-parts` modules
in aspects as configuration.

When the configuration depends on den context, or we can use den machinery
(quirks, custom classes, etc.) we inline them in den aspects.

### Hosts

The `/modules/hosts` folder contain the entity and aspect definitions for hosts.
The entity record is usually reserved for metadata that is used to policy dispatch.
The aspect is used to actually dispatch configuration to the specific host.

Some aspects are pretty simple and are just one inclusion; so they are done
with host aspect inclusion.
Some are not though; so they have policies that depend on the entity.

### Users

The `/modules/users` folder contain the aspect definitions corresponding to users.

#### User Entity Record

Since user entities are sub-entities for each host; the user entity definition
is defined in each hosts' configuration usually.
The meta-data of each users' capability on a given machine is host-specific data,
so it makes sense there.

Den has no built-in way to treat a user across a fleet collectively; since
user entities are tied to hosts, are are not fleet wide.
To do a users' entity record globally; or where I want host-specific behavior
but contained in a users' config directory; I use a conditional entity module.

```
{lib, ...}: {
  # Global default
  den = {
    # Global default with schema module
    schema.user = {config, lib, ...}: {
      config = lib.mkIf (config.name == "username") {
        <some-option> = lib.mkDefault <some-value>;
      };
    };

    # Host-specific info by just defining them here
    hosts =
    {
      <hostname1> = <value1>;
      <hostname2> = <value2>;
    }
    |> lib.mapAttrs (_: v:
      users.<username>.<option> = v;
    });
  };
}
```

This pattern is to be used as sparingly as possible though.

### Systems

The top-level `den.aspects.system` is the aspect that configures the base of
a type of system; and included unconditionally in hosts.

Right now, each configuration morsel needed by a system is a flake-parts module
with the naming `<system>-<feature>` and imported in the top-level module
`den.aspects.system.<class>`, granted they are simple static configurations.

For complicated, and potentially different backend configuration;

- Define needed metadata to `den.schema.host` if needed.
- Define needed modules as `flake.modules.<class>.<system-name>-<feature>[-<backend>]`.
- Provide a new (non-parametric) aspect directly under system; `system._.<feature>`
- Provide a full dispatch policy under this aspect; `system._.<feature>.policies.<policy-name>`
- Include this policy in the parent `system` aspect. (All hosts will execute this policy.)
- Forking behavior should be done with provides; `system._.<feature>._.<backend>`

IMPLICATIONS:

- For different systems; each system will need a different class and can't be reused;
  since i'm using aspect class key as my system differentiator.
  (Might need to change this when I try to do rp5 and vms for example; right now it's bespoke).

### Applications

There is a top-level `den.aspects.applications` aspect for collecting specific
application configurations.
All apps, no matter their domain, should declare individual `applications._.<app>`
sub-aspects.
All app aspects should be non-parametric, and actually have a `provides.to-users`
that does their userspace configuration; even for os level config.
This enables the apps to be enabled user-specific with including the sub-aspect,
or to all users in a system with the following;

```
# Dispatch application to one user on one host
den.aspects.<username>.provides.<hostname> = {
  includes = [den.aspects.applications._.<app>._.to-users];
}
# Dispatch application to all users on one host; with the builtin user fanout
den.aspects.<hostname> = {
  includes = [den.aspects.applications._.<app>];
}
```

If existence of a feature needs system config, the os level classes do walk up;
so if they are enabled the modules will be included.
Duplication of modules coming in from fanned out user scopes shouldn't be a problem
due to every module getting a top level `key` attribute; all module resolution
dedupes these.

The only config at the bare app aspect level should be for classes dependent on
context; and that's preferably done through policies.
If an app needs policies and schema info to dispatch; they can do it in their aspect.

There is also a top level `collections` aspect, which works as a container for bulking
applications together.

### Utilities

Each utility should get their top level aspect; because it can get complicated.
