# ZSH config
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    schema = {
      host = {
        includes = [
          den.aspects.shell.policies.zsh-host-dispatch
        ];
        options = {
          shell = lib.mkOption {
            type = lib.types.submodule {
              options = {
                zsh = lib.mkOption {
                  description = "Enable zsh on this host";
                  default = true;
                  type = lib.types.bool;
                };
              };
            };
          };
        };
      };
      user.includes = [
        den.aspects.shell.policies.zsh-user-dispatch
      ];
    };

    # Aspect
    aspects.shell = {
      # Dispatch policies for explicit enable
      policies = {
        zsh-host-dispatch = {host, ...}:
          lib.optional
          host.shell.zsh
          (den.lib.policy.include den.aspects.shell._.zsh);
        # Get the default user shell
        zsh-user-dispatch = {host, ...}:
          lib.optional
          host.shell.zsh
          (den.lib.policy.include den.aspects.shell._.zsh._.to-users);
      };

      # Aspect
      provides.zsh = {
        name = "shell/zsh";
        nixos = {...}: {
          imports = [
            inputs.self.modules.generic.shell-zsh
            inputs.self.modules.nixos.shell-zsh
          ];
        };
        darwin = {...}: {
          imports = [
            inputs.self.modules.generic.shell-zsh
            inputs.self.modules.darwin.shell-zsh
          ];
        };
        provides.to-users = {
          host,
          user,
        }: {
          name = "shell/zsh(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.shell-zsh
            ];
          };
        };
      };
    };
  };

  flake.modules = {
    # Generic settings for both settings
    generic.shell-zsh = {...}: {
      key = "shell-zsh#generic";
      config = {
        programs.zsh = {
          enable = true;
          enableCompletion = true;
          enableBashCompletion = true;
        };
      };
    };
    # Nix-darwin settings
    darwin.shell-zsh = {...}: {
      key = "shell-zsh#darwin";
      config = {
        programs.zsh = {
          enableAutosuggestions = true;
          enableFastSyntaxHighlighting = true;
          enableFzfCompletion = true;
          enableFzfGit = true;
          enableGlobalCompInit = true;
          enableFzfHistory = true;
          enableSyntaxHighlighting = false;
        };
      };
    };
    # Configure zsh on nixos
    nixos.shell-zsh = {...}: {
      key = "shell-zsh#nixos";
      config = {
        # ZSH
        programs.zsh = {
          vteIntegration = true;
          syntaxHighlighting = {
            enable = true;
            highlighters = [
              "main"
              "brackets"
              "root"
            ];
            styles = {
              "root" = "fg=red,bold";
            };
          };
          autosuggestions = {
            enable = true;
            strategy = [
              "completion"
              "match_prev_cmd"
            ];
          };
          enableLsColors = true;
        };

        # Let zsh find system-based apps
        environment.pathsToLink = ["/share/zsh"];
      };
    };

    # Configure user-level zsh
    homeManager.shell-zsh = {
      config,
      pkgs,
      lib,
      ...
    }: {
      key = "shell-zsh#homeManager";
      config = {
        programs.zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          dotDir = "${config.xdg.configHome}/zsh";
          # History
          history = {
            expireDuplicatesFirst = true;
            extended = true;
            ignoreAllDups = true;
            path = "${config.home.homeDirectory}/.cache/zsh/history";
            share = true;
          };
          historySubstringSearch = {
            enable = true;
            searchDownKey = ["^[[B" "\${terminfo[kcud1]}"];
            searchUpKey = ["^[[A" "\${terminfo[kcuu1]}"];
          };
          plugins = [
            {
              name = "zsh-completions";
              src = pkgs.zsh-completions;
            }
            {
              name = "nix-zsh-completions";
              src = pkgs.nix-zsh-completions;
              file = "share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh";
            }
            {
              name = "zsh-history-substring-search";
              src = pkgs.zsh-history-substring-search;
              file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
            }
            {
              name = "fzf-tab";
              src = pkgs.zsh-fzf-tab;
              file = "share/fzf-tab/fzf-tab.plugin.zsh";
            }
          ];
          initContent = lib.mkOrder 1000 ''
            #--START--ZSH Config

            # Function to get nix program location
            nix-getPackage () {
              this_link="$(which "''${1}")"
              readlink "''${this_link}"
            }

            # Set editor default keymap to vi (`-v`) or emacs (`-e`)
            bindkey -v

            # Make completion case-insensitive
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
            # Get colored ls completionss
            zstyle ':completion:*' list-colors  "''${(s.:.)LS_COLORS}"
            # Disable native menu in favor of fzf menu, and get directory previews
            zstyle ':completion:*' menu no
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
            zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

            #---END---ZSH Config

          '';
        };
      };
    };
  };
}
