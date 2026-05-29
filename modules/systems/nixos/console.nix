# Nixos systems console settings
{...}: {
  flake.modules = {
    nixos = {
      console = {pkgs, ...}: {
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
    };

    # Set colormap through stylix
    stylix = {...}: {
      stylix.targets.console = {
        enable = true;
        colors.enable = true;
      };
    };
  };
}
