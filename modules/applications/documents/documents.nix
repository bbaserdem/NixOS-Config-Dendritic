# Document related software suite
{inputs, ...}: {
  # Den
  den = {
    aspects.documents = {
      # Base aspect
      name = "documents";
      # Global dispatch
      provides.to-users = {
        host,
        user,
      }: {
        name = "documents(${user.userName}@${host.name})";
        # Modules to load for full audio management collection
        homeManager = {...}: {
          imports = with inputs.self.modules.homeManager; [
          ];
        };
      };

      # Specific applications
      provides.calibre = {
        name = "documents/calibre";
        provides.to-users = {
          host,
          user,
        }: {
          name = "documents/calibre(${user.userName}@${host.name})";
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.calibre
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.calibre
            ];
          };
        };
      };
      provides.okular = {
        name = "documents/okular";
        provides.to-users = {
          host,
          user,
        }: {
          name = "documents/okular(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.okular
            ];
          };
        };
      };
      provides.zotero = {
        name = "documents/zotero";
        provides.to-users = {
          host,
          user,
        }: {
          name = "documents/zotero(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.zotero
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Calibre is broken on nix-darwin, use brew
    darwin.calibre = {...}: {
      key = "calibre#darwin";
      config = {
        homebrew.casks = ["calibre"];
      };
    };

    homeManager = {
      zotero = {pkgs, ...}: {
        key = "zotero#homeManager";
        # Install these apps to userspace
        config = {
          home.packages = with pkgs; [
            zotero # Reference manager
          ];
        };
      };
      okular = {
        pkgs,
        lib,
        ...
      }: {
        key = "okular#homeManager";
        # Install these apps to userspace
        config = {
          home.packages = with pkgs; (
            [
            ]
            ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              kdePackages.okular
            ])
          );
        };
      };
      calibre = {
        pkgs,
        lib,
        ...
      }: {
        key = "calibre#homeManager";
        # Install these apps to userspace
        config = {
          home.packages = with pkgs; (
            [
            ]
            ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              calibre # Darwin broken on nixpkgs
            ])
          );
        };
      };
    };
  };
}
