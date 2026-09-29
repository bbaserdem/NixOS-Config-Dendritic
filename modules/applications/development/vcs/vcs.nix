# Common VCS tooling dispatch
{
  inputs,
  lib,
  den,
  ...
}: {
  den = {
    schema.host = {
      includes = [
        den.aspects.development.policies.vcs-dispatch
      ];
      options = {
        development = lib.mkOption {
          type = lib.types.submodule {
            options = {
              vcs = lib.mkOption {
                description = "VCS configuration";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Whether to enable VCS tooling on this host.";
                      default = true;
                      type = lib.types.bool;
                    };
                    tools = lib.mkOption {
                      description = "Which VCS'es to install";
                      default = ["git" "jujutsu"];
                      type = lib.types.listOf (lib.types.enum [
                        "git"
                        "jujutsu"
                      ]);
                    };
                    providers = lib.mkOption {
                      description = "Which external forge integrations to do";
                      default = [];
                      type = lib.types.listOf (lib.types.enum [
                        "github"
                        "forgejo"
                        "gitlab"
                      ]);
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    aspects.development = {
      # Policy for enables
      policies.vcs-dispatch = {host, ...}:
        lib.optionals
        host.development.vcs.enable
        (
          [
            (den.lib.policy.include den.aspects.development._.vcs)
          ]
          ++ (
            builtins.map
            (n: (den.lib.policy.include den.aspects.development._.vcs._.${n}))
            host.development.vcs.tools
          )
        );

      provides.vcs = {
        name = "development/vcs";
        # Auto-fetch platform providers
        includes = [
          den.aspects.development._.vcs._.platforms
        ];
        # User dispatch for common tooling
        provides.to-users = {
          host,
          user,
        }: {
          name = "development/vcs(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.vcs-settings
            ];
          };
        };

        # Platform integration
        provides.platforms = {
          name = "development/vcs/platforms";
          provides.to-users = {
            host,
            user,
          }: {
            name = "development/vcs/platforms(${user.userName}@${host.name})";
            # Fetch wanted modules if they are defined
            darwin = {...}: {
              imports =
                host.development.vcs.providers
                |> builtins.map (
                  n:
                    inputs.self.modules.darwin."vcs-provider-${n}" or {}
                );
            };
            homeManager = {...}: {
              imports =
                host.development.vcs.providers
                |> builtins.map (
                  n:
                    inputs.self.modules.homeManager."vcs-provider-${n}" or {}
                );
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # In darwin, install github from brew
    darwin.vcs-provider-github = {...}: {
      key = "vcs-provider-github#darwin";
      config = {
        # Install github app from homebrew
        homebrew.casks = ["github"];
      };
    };
    homeManager = {
      # Global tooling
      vcs-settings = {...}: {
        key = "vcs-settings#homeManager";
        config = {
          # Enable delta for diff formatting
          programs.delta = {
            enable = true;
            enableGitIntegration = true;
            enableJujutsuIntegration = true;
          };
        };
      };
      # Forgejo / Gitea
      vcs-provider-forgejo = {pkgs, ...}: {
        key = "vcs-provider-forgejo#homeManager";
        config = {
          home.packages = with pkgs; [
            tea
          ];
        };
      };
      # Gitlab
      vcs-provider-gitlab = {pkgs, ...}: {
        key = "vcs-provider-gitlab#homeManager";
        config = {
          home.packages = with pkgs; [
            glab
          ];
        };
      };
      # Github
      vcs-provider-github = {
        pkgs,
        config,
        lib,
        ...
      }: {
        key = "vcs-provider-github#homeManager";
        config = {
          # Github cli tooling
          programs.gh = {
            enable = true;
            gitCredentialHelper.enable = true;
            settings = {
              editor = config.home.sessionVariables.EDITOR or "nvim";
              git_protocol = "ssh";
            };
            extensions = with pkgs; [
              gh-s
              gh-i
              gh-f
              gh-poi
              gh-eco
              gh-notify
              gh-skyline
              gh-contribs
              gh-screensaver
              gh-markdown-preview
            ];
          };
          programs.gh-dash = {
            enable = true;
          };
          home.packages = with pkgs; (
            [
            ]
            ++ ( # Linux only packages
              lib.optionals pkgs.stdenv.hostPlatform.isLinux [
                github-desktop
              ]
            )
          );
        };
      };
    };
  };
}
