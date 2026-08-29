# Nixos systems console settings
{lib, ...}: {
  den = {
    aspects.system = {host}: {
      stylix = lib.mkIf (host.class == "nixos") {
        targets.console = {
          enable = true;
          colors.enable = true;
        };
      };
    };
  };

  flake.modules.nixos.nixos-console = {pkgs, ...}: {
    console = {
      earlySetup = true;
      # Set console font
      font = "ter-powerline-v24b";
      packages = with pkgs; [
        terminus_font
        powerline-fonts
      ];
      # Set keymap of console
      keyMap = "dvorak";
    };
  };

  # TODO: REmove after den migration
  # Set colormap through stylix
  flake.modules.nixos.stylix = {...}: {
    stylix.targets.console = {
      enable = true;
      colors.enable = true;
    };
  };
}
