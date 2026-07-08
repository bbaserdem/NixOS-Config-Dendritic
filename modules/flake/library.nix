{
  lib,
  config,
  ...
}: {
  # Definition of common boilerplate functions used throughout this flake;
  # Define them sequential in the let binding to set recursive reference
  # Then inherit them in the output

  # These should only be standalone functions; should not touch flake-parts
  # config; otherwise we hit infinite recursion

  # Flake-parts doesn't automagically have a lib output spec defined
  options = {
    flake.lib = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.unspecified;
      default = {};
      description = "lib output for this flake.";
    };
  };

  config = {
    # Available as flake-module args
    _module.args.flib = config.flake.lib;

    # Actual functions
    flake.lib = let
      # --- String functions
      # Capitalize Strings
      capitalize = s:
        if s == ""
        then ""
        else
          (lib.toUpper (builtins.substring 0 1 s))
          + (builtins.substring 1 (builtins.stringLength s) s);

      # --- Directory traversal helpers
      # Clean up trailing slash
      trimTrailingSlash = path:
        if (path != "/") && (lib.hasSuffix "/" path)
        then trimTrailingSlash (lib.removeSuffix "/" path)
        else path;

      # Strip the root dir, once version
      stripRootOnce = rootDir: targetDir: let
        root = trimTrailingSlash rootDir;
        target = trimTrailingSlash targetDir;
        prefix = "${root}/";
      in
        if target == root
        then ""
        else if lib.hasPrefix prefix target
        then lib.removePrefix prefix target
        else throw "Target `${targetDir}` is not under `${rootDir}`";

      # Walk towards target
      walkToDir = rootDir: targetDir: let
        root = trimTrailingSlash rootDir;
        relative = stripRootOnce root targetDir;
        parts = lib.filter (part: part != "") (lib.splitString "/" relative);
      in
        lib.imap1 (
          index: _: "${root}/${lib.concatStringsSep "/" (lib.take index parts)}"
        )
        parts;

      # From (either string, or a list of strings) targets, strip root dir name
      stripRootDir = rootDir: targetDir:
        if builtins.isList targetDir
        then map (stripRootOnce rootDir) targetDir
        else stripRootOnce rootDir targetDir;

      # From a source directory; walk up to a target directory
      walkToDirRel = rootDir: targetDir:
        stripRootDir rootDir (walkToDir rootDir targetDir);
    in {
      # Inherit the functions we want to export
      inherit
        capitalize
        stripRootDir
        walkToDir
        walkToDirRel
        ;
    };
  };
}
