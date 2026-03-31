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
        data = with pkgs.unstable.vimPlugins; [
          {
            data = lze;
            lazy = false;
          }
          {
            data = lzextras;
            lazy = false;
          }
          plenary-nvim
          nui-nvim
          nvim-nio
          mini-base16
          nvim-lspconfig
        ];

        # These are default gui fonts
        extraPackages = with pkgs; [
          jetbrains-mono
          nerd-fonts.symbols-only
        ];
      };
    };
  };
}
