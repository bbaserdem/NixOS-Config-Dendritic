# Configuring jj
{...}: {
  flake.modules.home-manager.vcs = {
    config,
    pkgs,
    ...
  }: {
    programs = {
      # Main jujutsu tool
      jujutsu = {
        enable = true;
      };

      # TUI for jujutsu
      jjui = {
        enable = true;
      };

      # Also add userspace packages
      home.packages = with pkgs; [
        lazyjj # Lazygit like util for jj
      ];
    };
  };
}
