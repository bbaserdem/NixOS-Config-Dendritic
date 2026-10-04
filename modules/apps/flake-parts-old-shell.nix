# TODO: Nuke after den migration
{inputs, ...}: {
  flake.modules = {
    generic.shell = {...}: {
      key = "shell#generic";
      imports = with inputs.self.modules.generic; [
        shell-zsh
      ];
    };
    nixos.shell = {...}: {
      imports = with inputs.self.modules.nixos;
        [
          shell-bash
          shell-path
          shell-starship
          shell-zsh
          #shell-zsh-default
        ]
        ++ [
          inputs.self.modules.generic.shell-starship
        ];
    };
    darwin.shell = {...}: {
      imports = with inputs.self.modules.darwin; [
        shell-path
        shell-zsh
      ];
    };
    homeManager.shell = {...}: {
      imports = with inputs.self.modules.homeManager;
        [
          shell-alias
          shell-apps
          shell-bash
          development-direnv
          shell-fzf
          shell-man
          shell-starship
          shell-tmux
          shell-vivid
          shell-zsh
          shell-zoxide
        ]
        ++ [
          inputs.self.modules.generic.shell-starship
        ];
    };
  };
}
