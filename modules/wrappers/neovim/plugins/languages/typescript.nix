# Typescript editing plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.typescript = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-treesitter-parsers.typescript
        nvim-treesitter-parsers.tsx
        nvim-treesitter-parsers.javascript
        nvim-treesitter-parsers.java
        nvim-treesitter-parsers.javadoc
      ];
      extraPackages = with pkgs.unstable; [
        typescript-language-server
      ];
    };
  };
}
