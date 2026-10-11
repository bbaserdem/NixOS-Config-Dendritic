# Editor setup; just editorconfig for now
# TODO: Pull neovim from forcing defaults to be configured here instead
{
  den,
  lib,
  ...
}: {
  # Dispatch modules in aspect
  den = {
    # Host schema settings regarding enabled desktops
    schema.host = {
      includes = [
        den.aspects.development.policies.editor-host-dispatch
      ];
      options = {
        # Seperate host-wide option since this is always needed
        editor = lib.mkOption {
          description = "Which editor to use on this host";
          default = "neovim";
          type = lib.types.nullOr (lib.types.enum [
            "neovim"
          ]);
        };
        # Development tied options
        development = lib.mkOption {
          type = lib.types.submodule {
            options = {
              editor = lib.mkOption {
                description = "Main editor metadata on this host.";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Enable editor config for this host";
                      default = true;
                      type = lib.types.bool;
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
      # Policy
      policies = {
        editor-host-dispatch = {host, ...}:
          lib.optional
          (host.development.enable && host.development.editor.enable)
          (den.lib.policy.include den.aspects.development._.editor);
        editor-user-dispatch = {host, ...}:
          lib.optional
          (host.development.enable && host.development.editor.enable)
          (den.lib.policy.include den.aspects.development._.editor._.to-users);
      };

      # Default dev settings
      provides.editor = {
        name = "development/editor";
        provides.to-users = {
          host,
          user,
        }: {
          name = "development/editor(${user.userName}@${host.name})";
        };
      };
    };
  };

  flake.modules.homeManager.editor-editorconfig = {...}: {
    key = "editor-editorconfig#homeManager";
    config = {
      editorconfig = {
        enable = true;
        settings = {
          # Default
          "*" = {
            charset = "utf-8";
            end_of_line = "lf";
            trim_trailing_whitespace = true;
            insert_final_newline = true;
            max_line_width = 100;
            indent_style = "space";
            indent_size = 2;
          };
          # Python specific
          "*.py" = {
            indent_size = 4;
          };
          # Makefile
          "Makefile" = {
            indent_style = "tab";
          };
        };
      };
    };
  };
}
