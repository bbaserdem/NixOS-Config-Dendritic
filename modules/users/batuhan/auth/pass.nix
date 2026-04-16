# SSH configuration for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {config, ...}: {
    programs.password-store.settings = {
      PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
      PASSWORD_STORE_CLIP_TIME = "30";
      PASSWORD_STORE_GENERATED_LENGTH = "16";
    };

    home.shellAliases."cd-pass" = "cd ${config.programs.password-store.settings.PASSWORD_STORE_DIR}";
  };
}
