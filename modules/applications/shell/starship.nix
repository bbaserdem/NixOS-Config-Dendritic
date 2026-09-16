# Shell prompt
{...}: {
  flake.modules = {
    # Enable starship on system level
    nixos.shell-starship = {...}: {
      key = "shell-starship#nixos";
      config = {
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
    };

    # Enable starship on user level
    # We pull in nerd font symbols override
    homeManager.shell-starship = {
      pkgs,
      lib,
      ...
    } @ args: let
      starship =
        if (lib.hasAttrByPath ["osConfig" "programs" "starship"] args)
        then (args.osConfig.programs.starship.package or pkgs.starship)
        else pkgs.starship;
      nfToml = builtins.readFile "${starship}/share/starship/presets/nerd-font-symbols.toml";
      nfSettings = builtins.fromTOML nfToml;
    in {
      key = "shell-starship#homeManager";
      config = {
        programs.starship = {
          enable = true;
          package = starship;
          enableInteractive = true;
          settings =
            nfSettings
            // {
              follow_symlinks = true;
            };
        };
      };
    };
  };
}
