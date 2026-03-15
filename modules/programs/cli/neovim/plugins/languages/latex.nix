# Latex plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.latex = {
      # We should provide minimally only what's needed for editing
      # The specific latex environment should be provided by the system/devshell
      lazy = true;
      data = with pkgs.vimPlugins; [
        {
          lazy = false;
          data = vimtex;
        }
      ];
      extraPackages = with pkgs; [
        # Latex environment should be provided on a project basis
        pplatex # Latex log parsing tool
        texlivePackages.chktex # Linter, only
        neovim-remote # Client server for vimtex to run latexmk
        pstree
        bibtex-tidy # Latex cleaner
        tex-fmt
        ltex-ls-plus
        languagetool
      ];
    };
  };
}
