# Virtualization setup
{inputs, ...}: {
  den = {
    aspects.applications = {
      provides.virtualization = {
        # The windows is extra
        provides.windows = {
          name = "applications/virtualization/windows";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.virtualization-settings
            ];
          };
        };
        # User dispatch for interacting and virtualizing
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/virtualization(${user.userName}@${host.name})";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.virtualization-settings
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.virtualization-settings
            ];
          };
        };
      };
    };
  };

  # Enable libvirt in nixos
  flake.modules.nixos.virtualization-settings = {pkgs, ...}: {
    key = "virtualization-settings#nixos";
    config = {
      # Setup libvirt and virt-manager
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;

      # Enable USB redirection
      virtualisation.spiceUSBRedirection.enable = true;

      # Install virtio drivers
      environment.systemPackages = with pkgs; [
        spice-gtk
      ];
    };
  };
  flake.modules.nixos.virtualization-windows = {pkgs, ...}: {
    key = "virtualization-windows#nixos";
    config = {
      # Install virtio drivers
      environment.systemPackages = with pkgs; [
        virtio-win
      ];
    };
  };
  flake.modules.homeManager.virtualization-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "virtualization-settings#homeManager";
    config = lib.mkMerge [
      (
        # Set virt-manager to auto-connect to system in linux
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          dconf.settings = {
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = ["qemu:///system"];
              uris = ["qemu:///system"];
            };
          };
        }
      )
      (
        # Install UTM to darwin userspace
        lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          home.packages = with pkgs; [
            utm
          ];
        }
      )
    ];
  };
}
