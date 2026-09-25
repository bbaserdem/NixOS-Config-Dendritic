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

> [!NOTE]
> This behavior allows a single user config generated as both a standalone
> homeConfiguration, and as a <os>Configuration's managed homeManager instance.
> Even if the entities are different, the configuration refers to the same aspect.

### Scope

This is not explained as a first class concept in den, but it's very fundamental.
Practically, a `scope` is an environment that contains some entity records.
Mostly referred to by their **context**; `{host}`, `{host, user}` and `{home}`.

Individual _scopes_ are generated through the resolution pipeline.
There is a bunch of built-in machinery that creates this graph structure.

For example, the `yertengri` host entity, with two users; `wolframite` and `joeysaur`;
walks to the following scopes;

- `{host == "yertengri"; }` pure host scope.
- `{host == "yertengri"; user == "wolframite";}` the host-user scope
- `{host == "yertengri"; user == "joeysaur";}` another host-user scope.

The attrset of the contents of the current scope is called the **context**; or **ctx**.

### Schema

Schema is used to declare global behaviors to entities;

- `den.schema.<kind> = {...}`: Define an option for all entities of a given kind.
- `den.schema.conf = {...}`: Define an option for _ALL_ entities.
- `den.schema.<kind> = {<kind>, lib, ...}: {options.<...> = ...}`:
  Define a new config option for this kind.
  (Works with `conf` too for all kinds.)
  (Arguments mimic modules, but `<kind>` instead of `config`.)

### Aspects

An `aspect` is an attrset, that holds configuration behavior.
They are attached to a scope, and produce behavior which can depend on the scope.

> [!NOTE]
> **batteries** (`den.batteries`) are built-in aspects.

> [!NOTE]
> `den.default` is a reserved aspect;
> It's automatacially included in every scope.

Aspects mostly look like this; (example from den)

```
den.aspects.gaming = {
  nixos = { pkgs, ... }: { programs.steam.enable = true; };
  homeManager = { pkgs, ... }: { programs.mangohud.enable = true; };
  includes = [ den.aspects.performance ];
};
```

Aspects have an entry per `class`; a meaningful context.
Built in _class_ types are;

- _os_: Module for both `nixos` and `nix-darwin`.
- _nixos_: Module for `nixos`.
- _darwin_: Module for `darwin`.
- _homeManager_: Module for `home-manager`.

Aspects can be parametric; meaning they can be functions.
If they are, the aspect only activates for a matching scope.
`den.aspects.foo = {host}: {...};` activates in scopes with a host.
`den.aspects.bar = {home}: {...};` only activates in a home scope,
`den.aspects.baz = {host, user}: {...};` activates in a host + user scope.

> [!WARNING]
> Aspects can mix pipeline context arguments with module arguments
> by using the ellipsis notation.
> I find this a bit vague, and decided not to use it.
>
> My aspects, if they don't need context arguments, are all flake-parts modules,
> and are just imported with aspects.
> Aspects that need context arguments are parametric aspects instead.
>
> Parametric aspects are resolved later, so their downstream provides is not
> available in general. So parametric aspects should be dead-ends when it
> comes to the _provides_ nesting tree.

Aspects can include other aspects in `includes = [...]` list,
and exclude other aspects in `excludes = [...]` list.

Aspects can provide `sub-aspects` through the `provides.<subaspect>` key.

> [!NOTE]
> Non-parametric aspects are fixed-point.
> So they can refer to themselves.
> We use this to never use floating functions in `includes`

Aspects are deduped based on their `name` attribute.
They automatically get the name from their root level name.
(They do ignore the provides walk of their definition of their name,
which can cause issues so I usually name them explicitly.)

There are special provides names that have some automatic behavior;

- `provides.to-users`
  _to-users_ sub-aspect is fanned out to all downstream `{host, user}` scopes,
  if the parent aspect is in the `{host}` scope.

  > [!NOTE]
  > Needs the aspect to be parametric on `{home, user}`.
  > This is baked into the internal policy.
  > To also save from deduplication; I often explicitly name the aspects;
  > `name = "<root-aspect>/.../<immediate-parent-aspect>(${user.userName}@${host.name})"`

- `provides.to-hosts`
  _to-hosts_ sub-aspect is fired at the `{host, user}` scope, and the `os` content
  rides up to the `{host}` scope.
  (This is just a naming convention, this behavior is identical with the parent aspect.)

- `provides.<username>`
  _username_ sub-aspect is auto-enabled on `{host, user == <username>}` scope,
  if the parent aspect is in the `{host}` scope.

- `provides.<hostname>`
  _hostname_ sub-aspect is auto-enabled on `{host == <hostname>}` scope,
  if the parent aspect is in the `{host}` or `{home}` scope.

- `provides.<aspect>`
  If the sub-aspect name is the same as the parent one; it is auto-included.
  (This is not documented behavior, don't use this behavior.)

> [!WARNING]
> Entity `<kind>` names are also reserved; don't use them.
> I specifically use `system` and not `systems` for this.

The built-in behavior graph of aspects, and their _class_ modules is the following;
(`host`s modules here means the list of modules used to create the flake output.)

|   Class key   | `{host}` scope                                           | `{host, user}` scope                                                                             | `{home}` scope            |
| :-----------: | :------------------------------------------------------- | :----------------------------------------------------------------------------------------------- | :------------------------ |
|     `os`      | Merged to *host*s modules                                | Merged to the parent _host_ modules                                                              | No-op                     |
|    `nixos`    | Merged to *host*s modules; if `<host>.class == "nixos"`  | same, rides up                                                                                   | No-op                     |
|   `darwin`    | Merged to *host*s modules; if `<host>.class == "darwin"` | same, rides up                                                                                   | No-op                     |
| `homeManager` | No-op`                                                   | Sent to `home-manager.users.<user>` for the host if `builtins.elem "homeManager" <user>.classes` | Merged to *home*s modules |

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
