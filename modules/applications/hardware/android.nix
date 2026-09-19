# Configuring ADB
{inputs, ...}: {
  # Configuration aspect for this hardware
  den = {
    aspects.hardware = {
      provides.android = {
        name = "hardware/android";
        # Android configuration
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.android-settings
          ];
        };
        # Home-manager configuration
        provides.to-users = {
          user,
          host,
        }: {
          name = "hardware/android(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.android-settings
            ];
          };
        };
        # Emit port quirk for opening access for adb networking
        local-ports = [
          {
            port = 4747;
            proto = "all";
          }
        ];
      };
    };
  };

  # Modules
  flake.modules = {
    # Nixos module (only nixos available for now)
    nixos.android-settings = {pkgs, ...}: {
      key = "android-settings#nixos";
      config = {
        # Enable droidcam; and set up kernel modules
        programs.droidcam.enable = true;

        # Enable the gui for droidcam (use android phone as webcam)
        environment.systemPackages = with pkgs; [
          v4l-utils
          android-tools
        ];
      };
    };
    # Home manager; install go-mtpfs
    homeManager.android-settings = {pkgs, ...}: {
      key = "android-settings#homeManager";
      config = {
        # Enable mtpfs in userspace
        home.packages = with pkgs; (
          [
          ]
          ++ (
            # go-mtpfs, and mtpfs is broken on darwin
            lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              go-mtpfs
              mtpfs
            ]
          )
        );
      };
    };
  };
}
