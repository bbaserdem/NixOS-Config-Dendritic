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
- **Utilities**: Not exactly programes, but more like runners and processes.
  Things such as _networkmanager_, _avahi_ etc.
- **Services**: Programs that are _serving_ functions, not just direct point of contact.
  Things such as _syncthing_, _paperless_ etc.

---

## Flake-Parts

Usage of `flake-parts` in this flake.

### Modules

---

## Den

The setup guide of den in this flake.

### Aspects

- Features should use aspect names and nesting for containerization.
- Framework features should not use `categories`, others should.
- Dispatch operations should use `provides` (or `_` directly)
- Sub-categories can be nested without worry.
- Collection should use naming such as `base`, `extras`, `full`, `minimal`.

```
# Use category and subcategory name for an aspect
den.aspects.<category>[.<subcategory>].<feature> = { ... };

# For the matcher-dependent features; needs to be done explicity
# Prefer _ when top-level, and provides otherwise
den.aspects.<category>.<feature>._.<user> = {
    provides.to-hosts = {...};
};
# Collection aspects
den.aspects.<category>.<collection> = {
    includes = with den.aspects.<category>; [
        <feature-1>
        <feature-2>
        ...
    ];
};
```
