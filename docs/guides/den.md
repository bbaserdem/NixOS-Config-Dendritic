# Den

It's complicated; but `den` is a framework that bring aspect oriented paradigm
to the flake specification.

This is my write-up to help understand exactly what's happening.

## Conceptual Breakdown

Den has a 3 level evaluation pipeline;

- **Stage 0**; Schema registry, and entity evaluation.
- **Stage 1**: Resolution pipeline, create scopes, collect aspect buckets of scopes.
- **Stage 2**: Instantiate `intoAttr`

### Entity

An `entity` is a record; they are basically an _attrset_ holding some information.
Entities are typed, they have a `kind`.

For example, the entity for my PC would be a `host` kind _entity_ with the name `yertengri`.

There are 3 relevant `kind`s built-in to den's entity schema;

- `hosts`: Named by _hostname_, a host is an entity that describes a machine.
  For the flake, having a host entity outputs an entry to `nixosConfigurations`,
  `darwinConfigurations` or `systemConfigs` entry.
  (Which one is auto-detected; and this detection is available as `class`).

- `homes`: Named by _username@hostname_, a home is an entity that describes a
  standalone home-manager configuration.
  For the flake, a home entity produces an entry to `homeConfigurations`.

> [!TIP]
> Home entities are completely seperate from other kind of entities.
> But, if a home entity's name is set as "<username>@<hostname>",
> den's built in behavior populates three reference fields;
>
> - `<home>.hostName` set to hostname
> - `<home>.host` set to the `den.hosts.<hostname>` entity if exists, stubs the entry if not.
> - `<home>.user` set to `den.hosts.<hostname>.users.<username>` if exists.
>   This machinery is built for cases where OS is nixos, but users are managed
>   with home-manager standalone.
>
> These also mimic those scopes, so the naming activates pulling the {host, user}
> scoped aspects into this {home} scope
>
> This is very confusing to me, and I'm choosing to not use this.
> To me, a host is a container that can hold users; so doesn't make sense
> to abstract this away from hosts.

- `users`: Named by _username_, a user is a **sub-entity** on their host.
  A user entity does not have it's own definition, it only lives implicitly inside
  a hosts' `den.hosts.<sys>.<hostName>.users.<users>` entry.
  `user` entities have `classes` list, declares what they are going to use.

> [!IMPORTANT]
> My mental model was that flake outputs are one level; whether it be
> nixos, darwin or standalone home-manager, and then users are under them.
> With the restriction that a standalone home-manager config would be a
> system level configuration, and then contain just one user.
>
> Den does NOT operate on this construction AT ALL, when it comes to entities.
> A standalone home configuration is completely abstracted away from a host.
> My plan is to just not use homes, and create new host kinds that produces
> standalone user entries.

Each entity gets assigned a native _aspect_ `den.aspects.${<entity>.name}`.
This is where an entities' behavior can be configured.

### Scope

This is not explained as a first class concept in den docs, but it's very fundamental.
A `scope` is an environment that contains some entity records.
Mostly referred to by their **context**; `{host}`, `{host, user}`.

All _scope_ instances are generated through the resolution pipeline.
There is a bunch of built-in machinery that creates this graph structure.

For example, the `yertengri` host entity, with two users; `wolframite` and `joeysaur`;
walks to the following scopes;

- `{host.name == "yertengri"; }`; usually referred to as the _host scope_.
- `{host.name == "yertengri"; user.userName == "wolframite";}`; the _host-user scope_. (Or the _user scope_).
- `{host.name == "yertengri"; user.userName == "joeysaur";}` another user scope.

The attrset of the contents of the current scope is called the **context**; or **ctx**.

Scopes get attached aspects and policies.
The policies activate, and then modulate the scopes such as;

- Fan out new child scopes
- Realize parametric aspects
- Pull in other aspects
- Create new records inside the scope
- Instantiate; meaning route the scope's buckets to appropriate places.

> [!WARNING]
> The policies registered for a scope fire once; and that scope is marked as resolved.
> This means that nested policies don't work; if one policy pulls in another policy,
> the pulled in policy won't actually fire.
> It's not clear if this is intentional or is a bug.
> Either way, nested policy invokations don't work.
> This is annoying; the biggest headache I have run into is the main routing policy
> maps provides.to-users/hosts doesn't work if the parent aspect is provided to
> the scope using a policy; since this fan out is a policy itself.

### Schema

Schema is used to declare global behaviors to entities;

- `den.schema.<kind> = {...}`: Configure all entities of a given kind.
- `den.schema.conf = {...}`: Configure for _ALL_ entities.

Schema definitions work like modules; with custom den spec fields overloaded.

- `den.schema.<...>.include = [...];`:
  Attach _policies_ or _aspects_ to all _scopes_ for this _kind_.
- `den.schema.<kind> = {<kind>, lib, ...}: {options.<...> = ...}`:
  Define a new config option for this kind.
  (Arguments mimic nixos modules, but `<kind>` instead of `config`.)

> [!WARNING]
> Den limitation; when defining both non-flat option definitions and den specs,
> flat out assignment doesn't work because the module system doesn't recognize den specs.
> The way to work around it is to either do it in different files;
> or to have `den.schema.<...> = { includes = [...]; imports = [({...}: {options = {...};})];}`.
> Anonimizing the module and keeping it on it's own works because den, like flake-parts,
> merges all the definitions across files as modules.

### Aspects

An `aspect` is an attrset, that holds configuration behavior.
They are attached to a scope, and produce behavior which can depend on the scope.

> [!NOTE]
> **batteries** (`den.batteries`) are built-in aspects and policies.

> [!NOTE]
> `den.default` is a reserved aspect;
> It's automatically included in every scope.

Aspects mostly look like this; (example from den, not my flake)

```
den.aspects.gaming = {
  includes = [ den.aspects.performance ];
  nixos = { pkgs, ... }: { programs.steam.enable = true; };
  homeManager = { pkgs, ... }: { programs.mangohud.enable = true; };
};
```

The spec is as follows;

- `name` and `description` a den field to describe. (_name_ is used for dedupe in a scope.)
- `includes` which pulls in other _aspects_ or _policies_ to the included scope.
- `excludes` the opposite behavior.
- `provides` which can contain sub-aspects. (Can be reached with the `<base>._.<sub>` shorthand.)
- `policies` attrset to register associated policies.

Then mainly, aspects have an entry per `class`.
Each class type accepts a _module_ (or a flat _attrset_).
Main built in _class_ types are;

- _os_: Module for both `nixos` and `nix-darwin`.
- _nixos_: Module for `nixos`.
- _darwin_: Module for `darwin`.
- _homeManager_: Modules for `home-manager`.

> [!NOTE]
> Actually only the built-in aspects accept general modules.
> Custom classes only get a subset of context arguments; be mindful.

> [!WARNING]
> Aspects can inject pipeline context arguments to the module arguments
> if the context contains matching record names (host, user, etc.)
> from the ellipsis notation used for module arguments.
> I find this a bit vague, and opt to not use it whenever possible.
>
> My aspects, if they don't need context arguments, are all flake-parts modules,
> and are just imported by aspect class modules.
> Aspects that need context arguments are made into inline class modules
> of parametric aspects instead.

Depending on the policy of the current scope, the content of these class modules
are merged into specific places that instantiates the _aspect_.

Aspects can be parametric; meaning they can be functions.
If they are, the aspect can only activates for a matching scope;

- `den.aspects.foo = {host}: {...};` activates in scopes with a host.
- `den.aspects.bar = {home}: {...};` only activates in a home scope,
- `den.aspects.baz = {host, user}: {...};` activates in a host + user scope.

> [!WARNING]
> Parametric aspects are lazy realized after context dispatch locks in,
> Their downstream provides is not available in general.
> Parametric aspects should be dead-ends when it comes to the _provides_ nesting tree.

Aspects are deduped based on their `name` attribute.
They automatically get assigned a name from their root level name.
They do ignore the provides walk of their definition of their name.
I name them explicitly to avoid issues with this.
The naming scheme is `<parent-aspect>/.../<node>[(<username>@<hostname>)]`
Which results in the following naming scheme;

- Regular aspect at `den.aspects.foo._.bar._.baz` has `name = "foo/bar/baz";`.
- Parametric aspect at `den.aspects.foo._.bar` might be;
  `name = "foo/bar(@${host.name})";` if host scope
  `name = "foo/bar(${user.userName}@${host.name})"` if user scope.
- I omit the last aspect name for the special provides, which always have to be parametric.
  `den.aspects.foo._.bar._.to-users` then has the name set as
  `name = "foo/bar(${user.userName}@${host.name})"`

There are special _provides_ names that have some automatic behavior;

- `provides.to-users`
  _to-users_ sub-aspect is fanned out to all downstream `{host, user}` scopes.
  (If the parent aspect is in the `{host}` scope.)

  > [!NOTE]
  > Needs the aspect to be parametric on `{home, user}`.
  > This is baked into the internal policy.

- `provides.to-hosts`
  _to-hosts_ sub-aspect is fired at user scopes,
  and the `os` content rides up to the `{host}` scope.
  (This is just a naming convention, this behavior is identical with the parent aspect.)

  > [!NOTE]
  > Apparently, the `os`, `nixos` and `darwin` class modules riding up to host
  > scope is unintended behavior in den; and this might be removed and made into
  > a opt-in battery instead.
  > I use this a lot; since a lot of my user scope modules are parametric,
  > they can't use `to-host` dispatch route to configure upstream hosts.

- `provides.<username>`
  _username_ sub-aspect is auto-enabled on `{host, user == <username>}` scope,
  if the parent aspect is in the `{host}` scope.

- `provides.<hostname>`
  _hostname_ sub-aspect is auto-enabled on `{host == <hostname>}` scope,
  if the parent aspect is in the `{host}` or `{home}` scope.

- `provides.<aspect>`
  If the sub-aspect name is the same as the parent one; it is auto-included.
  (This is not documented behavior, don't use this behavior.)

> [!NOTE]
> As above, these automatic dispatches only work if the parent aspect
> is not parametric, and is flat included. (not policy-fed to the scope)

> [!WARNING]
> Entity `<kind>` names are also reserved; don't use them.
> I specifically use `system` and not `systems` due to this.

The built-in behavior graph of aspects, and their _class_ modules is the following;
(`host`s modules here means the list of modules used to create the flake output.)

|   Class key   | `{host}` scope                                           | `{host, user}` scope                                                                              | `{home}` scope            |
| :-----------: | :------------------------------------------------------- | :------------------------------------------------------------------------------------------------ | :------------------------ |
|     `os`      | Merged to *host*s modules                                | Merged to the parent _host_ modules                                                               | No-op                     |
|    `nixos`    | Merged to *host*s modules; if `<host>.class == "nixos"`  | same, rides up                                                                                    | No-op                     |
|   `darwin`    | Merged to *host*s modules; if `<host>.class == "darwin"` | same, rides up                                                                                    | No-op                     |
| `homeManager` | No-op                                                    | Sent to `home-manager.users.<user>` for the host iff `builtins.elem "homeManager" <user>.classes` | Merged to *home*s modules |

Which I don't like; I am aiming to create the following model;

- `os`, `nixos`, `darwin` creates the configuration as usual as in `host` modules.
- For each host containing users, there is also a `user`'s standalone _home-manage_ output.
  (To be referred to as `user`'s modules in this next table)

|        Class key        | `{host}` scope                 | `{host, user}` scope                |
| :---------------------: | :----------------------------- | :---------------------------------- |
| `os`, `nixos`, `darwin` | Merged to *host*s modules      | Merged to the parent _host_ modules |
|      `homeManager`      | Merged to each `user`s modules | Merged to the users' _user_ modules |

(The behavior, of nixos and darwin outputs sending each users' user modules to `home-manager.users.<user>` if that user has class homeManager is retained.)

> [!NOTE]
> Obvious, but including an aspect in a parent scope (i.e. {host})
> does NOT propagate to child scopes ({host, user})
> The dispatch is only upstream, it's one way only.
