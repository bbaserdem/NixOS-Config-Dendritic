{inputs, ...}: {
  # Sops secrets provisioning
  # https://github.com/Mic92/sops-nix
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Load into contexts
  flake.modules = {
    generic.secrets = {...}: {
      # Default ssh key locations
      sops.age = {
        sshKeyPaths = [
          "/etc/ssh/ssh_age_host_ed25519_key"
          "/etc/ssh/ssh_age_all_ed25519_key"
        ];
        generateKey = false;
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
    homeManager.secrets = {config, ...}: {
      imports = [
        inputs.sops-nix.homeModules.sops
      ];
      # Default key file location
      sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    };
  };
}
