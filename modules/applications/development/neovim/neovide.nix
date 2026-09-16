# Configuring neovide that depends on neovim
{inputs, ...}: {
  # Add new aspect
  den = {
    aspects.applications = {
      provides.neovim = {
        # Neovide accessible through aspects.applications._.neovim._.neovide
        provides.neovide = {
          provides.to-users = {
            host,
            user,
          }: {
            # Collission protection
            name = "applications/neovim/neovide(${user.userName}@${host.name})";
            # Dispatch the home-manager module
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.neovim-neovide
              ];
            };
            # Establish stylix theme
            stylix = {lib, ...}: {
              targets.neovide = {
                enable = true;
                fonts.enable = lib.mkDefault true;
                opacity.enable = true;
              };
            };
          };
        };
      };
    };
  };

  # Home manager module to install full neovim module
  flake.modules.homeManager.neovim-neovide = {
    lib,
    config,
    pkgs,
    options,
    ...
  }: {
    key = "neovim-neovide#homeManager";
    config = lib.mkMerge [
      {
        # Install neovide in our system
        programs.neovide = {
          enable = true;
          # Pull neovide from unstable
          package = pkgs.unstable.neovide;
        };
      }
      (
        # Link to neovim wrapper editor if enabled
        lib.optionalAttrs (lib.hasAttrByPath ["wrappers" "neovim"] options) {
          programs.neovide.settings.neovim-bin =
            lib.getExe
            config.wrappers.neovim.wrapper;
        }
      )
    ];
  };
}
