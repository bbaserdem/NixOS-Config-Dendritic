# Code Style

Coding patterns I tend to use in this flake.

## Markdown

All markdown files should use good truncation rules for long lines.
Never write a paragraph as a line; try to break around 100 characters.
[neovim](../software/neovim.md) should have a formatter, so shouldn't be a problem.

## Variables

I like to keep variables out of `let in` bindings as much as possible.
The only cases I prefer to use `let in` bindings are;

- Where something needs to be explicitly reused in multiple places in one file.
  Single point of reference keeps variables constant.
  (If this is needed across files, then the variable should be promoted to an option.)
- A function that belongs in one file is overly verbose in writing, and breaks
  narrative flow in the file making it harder to read.
- Combo of both; a large workflow can be decomposed into multiple functions,
  which the atoms can be reused around in the same file.
- Need recursive references in a logic flow, prefer using `let in` binding over `rec { }`.

## Nested functions

Whenever possible, I rather use pipe operators for multi-step transformations.
It makes things much easier to read, and conceptualizes processing pipeline
as seperate stages.

Aggressively prefer using pipe operators over composing functions;
improves readability (for me).

## Boilerplate to Library

Flake output schema has a `lib` output for libraries for other flakes to consume.
I use this space to keep boilerplate code, and it's available as a flake-parts
module argument `flib` to be pulled in as well.

Boilerplate functions should be defined in the file they are used in
if they are only used in that one file.
If it's used in multiple places, it should go in `modules/flake/library.nix`
where `flib` is wired.

## Modules

- If something is a module (`flake-parts`, `nixos`, `nix-darwin`, `home-manager`)
  it should be made explicit by taking module arguments, even when not needed.
  Meaning, `{...}: {}` notation should be used.

- Inside module blocks, if there is module keys besides `config`
  `config` should always be explicit.
  (i.e. `imports` or `options` is defined, then config should be explicit.)
  Only if `config` is the only definition, is it allowed to be implicit.
  Anti-pattern is `{...}: {imports = [...]; <option>.enable = true; }`,
  correct way is `{...}: {imports = [...]; config = {<option>.enable = true;}; }`
  (Coupled with the next item, this means we have explicit `config` almost all the time.)

- Modules should have the top-level `key` defined to make use of module deduplication.
  Usually, this key is to be set to `<module-name>$<module-class>` but other naming
  can be followed when appropriate.

- `config` and `options` should always be top level attrsets, not dot notationed.
  Anti-pattern is `{...}: {config.<option>.enable = true;}`;
  correct way is `{...}: { config = { <option>.enable = true;};}`

This may be too verbose, and sometimes hard to read.
But shorthand conventions mess up with my brain,
explicitness makes things easier to follow for me.

## Den

Styling in `den`

### Entity

- **No bare `home` entities allowed.**
  We have not set it up yet; but for standalone home-manager outputs
  a record-only host of class `homeManager` is to be used.
  Every `user` record on hosts produces a standalone output as well.
  (Not set up yet)

### Aspects

- Den doesn't resolve parametric aspects until later, so don't have parametric
  aspects with provides; they are not reachable.

- For parametric aspects, _context_ arguments should always be divorced
  from _module_ arguments.

This is considered an anti-pattern;

```
den.aspects.<feature> = {host, config, ...}: {
  nixos = {
    ...
  };
};
```

Correct usage is;

```
den.aspects.<feature> = {host}: {
  nixos = {config, ...}: {
    ...
  };
};
```
