# Latex plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.latex = {
      # We should provide minimally only what's needed for editing
      # The specific latex environment should be provided by the system/devshell
      lazy = true;
      data = with pkgs.unstable.vimPlugins; [
        {
          lazy = false;
          data = vimtex;
        }
      ];
      runtimePackages = with pkgs.unstable; [
        # Latex environment should be provided on a project basis
        texlivePackages.chktex # Linter, for nvim-lint
        bibtex-tidy # Bibtex cleaner, for conform
        tex-fmt # Latex cleaner, for conform
      ];
    };
  };
}
