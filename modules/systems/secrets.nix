{inputs, ...}: {
  # Sops secrets provisioning
  # https://github.com/Mic92/sops-nix
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Load into contexts, generic gets loaded into nixos and darwin settings
  flake.modules = {
    generic.secrets = {config, ...}: {
      # Default ssh key locations
      sops = {
        defaultSopsFile = inputs.self + /secrets/host/${config.networking.hostName}/secrets.yaml;
        age = {
          sshKeyPaths = [
            "/etc/ssh/ssh_host_ed25519_key"
          ];
          generateKey = false;
        };
      };
    };
    nixos.secrets = {...}: {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
    };
    darwin.secrets = {...}: {
      imports = [
        inputs.sops-nix.darwinModules.sops
      ];
    };
    homeManager.secrets = {
      config,
      pkgs,
      lib,
      ...
    }: {
      imports = [
        inputs.sops-nix.homeModules.sops
      ];

      config = lib.mkMerge [
        {
          # Default key file location; where age keys are, etc
          sops = {
            defaultSopsFile = inputs.self + /secrets/user/${config.home.username}/secrets.yaml;
            age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
          };
        }
        (
          # Drop a symlink in the canonical directory in macos
          lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
            home.file."Library/Application Support/sops" = {
              source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/sops";
              force = true;
            };
          }
        )
      ];
    };
  };
}
