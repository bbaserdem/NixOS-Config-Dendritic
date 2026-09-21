# Document related software suite
{...}: {
  # Den
  # Modules
  flake.modules = {
    # Calibre is broken on nix-darwin, use brew
    darwin.document-applications = {...}: {
      key = "document-applications#darwin";
      config = {
        homebrew.casks = ["calibre"];
      };
    };

    homeManager.document-applications = {
      pkgs,
      lib,
      ...
    }: {
      key = "document-applications#homeManager";
      # Install these apps to userspace
      config = {
        home.packages = with pkgs; (
          [
            zotero # Reference manager
          ]
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            calibre # Darwin broken on nixpkgs
            kdePackages.okular
          ])
        );
      };
    };
  };
}
