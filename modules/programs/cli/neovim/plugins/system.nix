# System plugins
{...}: {
  flake.wrappers.neovim = {
    pkgs,
    config,
    lib,
    ...
  }: {
    config.specs = {
      # Specs for system plugins

      # Base plugins; list of plugins that should always exist
      system = {
        # If the minimal option is used, make sure we are still enabled
        enable = lib.mkIf config.settings.minimal (lib.mkDefault true);

        # System plugins can be lazy loaded besides package management
        lazy = true;
        data = with pkgs.vimPlugins; [
          {
            data = lze;
            lazy = false;
          }
          {
            data = lzextras;
            lazy = false;
          }
          {
            data = nvim-lspconfig;
            lazy = false;
          }
          plenary-nvim
          nui-nvim
          nvim-nio
          mini-base16
        ];
      };
    };
  };
}
