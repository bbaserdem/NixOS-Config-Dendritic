# Document related software
{...}: {
  flake.modules = {
    # Calibre is broken on nix-darwin, use brew
    darwin.docs = {...}: {
      homebrew = {
        casks = [
          "calibre"
        ];
      };
    };

    homeManager.docs = {
      pkgs,
      lib,
      ...
    }: {
      # Install these apps to userspace
      config = lib.mkMerge [
        {
          home.packages = with pkgs; [
            zotero # Reference manager
          ];
        }
        (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          home.packages = with pkgs; [
            calibre # Book library organizer (broken in darwin)
            kdePackages.okular
          ];
        })
      ];
    };
  };
}
