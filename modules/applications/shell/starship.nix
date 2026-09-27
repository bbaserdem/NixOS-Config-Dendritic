# Shell prompt
{...}: {
  # Modules
  flake.modules = {
    # Generic for both nixos and home-manager
    generic.shell-starship = {pkgs, ...}: {
      key = "shell-starship#generic";
      config = {
        programs.starship = {
          enable = true;
          package = pkgs.starship;
          # Presets loaded
          presets = [
            #"jetpack"
            "nerd-font-symbols"
          ];
          settings = {
            follow_symlinks = true;
            format = "$shell$all";
            # Shell icons; though i prefer not having this
            shell = {
              disabled = true;
              bash_indicator = " ";
              zsh_indicator = "󱉸 ";
              fish_indicator = "󰈺 ";
              powershell_indicator = " ";
              ion_indicator = " ";
              style = "cyan";
            };
            # Disable unused
            buf.disabled = true;
            cobol.disabled = true;
            conda.disabled = true;
            crystal.disabled = true;
            daml.disabled = true;
            dart.disabled = true;
            dotnet.disabled = true;
            fortran.disabled = true;
            gleam.disabled = true;
            haxe.disabled = true;
            helm.disabled = true;
            mojo.disabled = true;
            solidity.disabled = true;
            spack.disabled = true;
            vcsh.disabled = true;
            # Enable used
            direnv = {
              disabled = false;
            };
            memory_usage = {
              disabled = false;
            };
            os = {
              disabled = false;
            };
            sudo = {
              disabled = false;
            };
            vcs = {
              disabled = false;
              # TODO: include jj when this feature is in
              order = [
                # "jj"
                "git"
                "hg"
                "pijul"
                "fossil"
              ];
            };
          };
        };
      };
    };
    # Some options are nixos-only
    nixos.shell-starship = {...}: {
      key = "shell-starship#nixos";
      config = {
        programs.starship = {
          interactiveOnly = true;
          transientPrompt = {
            enable = false;
          };
        };
      };
    };
    # Some options are home-manager only
    homeManager.shell-starship = {...}: {
      key = "shell-starship#homeManager";
      config = {
        programs.starship = {
          enableInteractive = true;
          enableTransience = false;
        };
      };
    };
  };
}
