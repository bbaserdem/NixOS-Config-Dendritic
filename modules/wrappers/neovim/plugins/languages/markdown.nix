# Markdown plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.markdown = {
      lazy = true;
      data = with pkgs.unstable.vimPlugins; [
        nabla-nvim # Render latex equations
        mkdnflow-nvim # Navigate wiki links
        glow-nvim # Render markdown in nvim terminal
        render-markdown-nvim
      ];
      extraPackages = with pkgs.unstable; [
        vale # Linter
        glow # Markdown typesetter for terminal
        mdformat # Markdown formatter
        python3Packages.pylatexenc # Render latex eqns
      ];
    };
  };
}
