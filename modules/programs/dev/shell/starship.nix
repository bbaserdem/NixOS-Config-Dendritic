# Shell prompt
{...}: {
  flake.modules = {
    # Enable starship on system level
    nixos.shell = {...}: {
      programs.starship = {
        enable = true;
        interactiveOnly = true;
        presets = [
          #"jetpack"
          "nerd-font-symbols"
        ];
        settings = {
          follow_symlinks = true;
          format = "$shell$all";
          shell = {
            disabled = false;
            bash_indicator = " ";
            zsh_indicator = "󱉸 ";
            fish_indicator = "󰈺 ";
            powershell_indicator = " ";
            ion_indicator = " ";
            style = "cyan";
          };
        };
      };
    };

    # Enable starship on user level
    # We pull in nerd font symbols override
    homeManager.virtualization = {osConfig, ...}: let
      starship = osConfig.programs.starship.package;
      nfToml = builtins.readFile "${starship}/share/starship/presets/nerd-font-symbols.toml";
      nfSettings = builtins.fromTOML nfToml;
    in {
      programs.starship = {
        enable = true;
        enableInteractive = true;
        settings =
          nfSettings
          // {
            follow_symlinks = true;
          };
      };
    };
  };
}
