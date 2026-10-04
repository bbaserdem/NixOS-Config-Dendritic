# Container for old flake-parts code
# TODO: retire this after den migration
{inputs, ...}: {
  flake = {
    modules = {
      # Load into contexts, generic gets loaded into nixos and darwin settings
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
        sops = {
          # Use systemd for decryption
          useSystemdActivation = true;
        };
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

      # Stylix
      # Generic behavior settings for all contexts
      generic.stylix = {...}: {
        stylix = {
          enable = true;
          autoEnable = false;
        };
      };

      # Context-specific module loading
      nixos.stylix = {...}: {
        imports = [
          inputs.stylix.nixosModules.stylix
        ];
      };
      darwin.stylix = {...}: {
        imports = [
          inputs.stylix.darwinModules.stylix
        ];
      };

      # In standalone hm context, this module needs to be loaded
      # We do the enables here too
      homeManager.stylix-hms = {...}: {
        imports = [
          inputs.stylix.homeModules.stylix
          inputs.self.modules.homeManager.stylix
        ];
      };
    };
  };
}
