# Sidepulse setup
{...}: {
  # Modules

  # Option module
  flake.modules.homeManager.sidepulse-module = {
    pkgs,
    lib,
    config,
    ...
  }: let
    cfg = config.programs.sidepulse;
  in {
    key = "sidepulse-module#homeManager";
    # TODO: Make this into a full blown config module; along with JSON config
    options = {
      programs.sidepulse = lib.mkOption {
        description = "Sidepulse: led strip hardware";
        default = {};
        type = lib.types.submodule {
          options = {
            enable = lib.mkOption {
              description = "Whether to enable sidepulse in userspace";
              default = false;
              type = lib.types.bool;
            };
            package = lib.mkOption {
              description = "The package to install for sidepulse";
              default = null;
              type = lib.types.nullOr lib.types.package;
            };
            logDirectory = lib.mkOption {
              description = "Log directory for sidepulse agent-monitor";
              default = "${config.xdg.stateHome}/sidepulse/agent-monitor";
              type = lib.types.str;
            };
          };
        };
      };
    };

    config = lib.mkIf cfg.enable (
      lib.mkMerge [
        (
          # Install to userspace
          lib.mkIf (cfg.package != null) {
            home.packages = [cfg.package];
          }
        )
        (
          # Darwin setup
          lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (let
            sidepulseBin =
              if (cfg.package == null)
              then "${config.home.homeDirectory}/.local/bin/sidepulse"
              else (lib.getExe cfg.package);
          in {
            # Create log directory
            home.activation.sidepulseLogDirectory =
              lib.hm.dag.entryBetween
              ["setupLaunchAgents"]
              ["writeBoundary"]
              ''
                run mkdir -p ${lib.escapeShellArg cfg.logDirectory}
              '';
            # Register with launchd agents
            launchd.agents =
              {
                "io.sidepulse.agentstatus" = {
                  label = "status-bar";
                  args = [
                    sidepulseBin
                    "status-bar"
                    "start"
                    "--foreground"
                  ];
                  alive = false;
                };
                "io.sidepulse.service" = {
                  label = "service";
                  args = [
                    sidepulseBin
                    "service"
                    "run"
                  ];
                  alive = true;
                };
                "io.sidepulse.sdejectguard" = {
                  label = "sd-eject-guard";
                  args = [
                    (
                      if cfg.package == null
                      then "${config.xdg.dataHome}/sidepulse/sd-eject-guard/SidePulse Pro Eject Prevention"
                      else "${cfg.package}/libexec/sidepulse-sd-eject-guard"
                    )
                  ];
                  alive = true;
                };
              }
              |> lib.mapAttrs (name: data: {
                enable = true;
                config = {
                  Label = name;
                  ProgramArguments = data.args;
                  RunAtLoad = true;
                  KeepAlive = data.alive;
                  WorkingDirectory = config.home.homeDirectory;
                  StandardOutPath = "${cfg.logDirectory}/${data.label}.out.log";
                  StandardErrorPath = "${cfg.logDirectory}/${data.label}.err.log";
                  EnvironmentVariables = {
                    PYTHONUNBUFFERED = "1";
                    XDG_CONFIG_HOME = config.xdg.configHome;
                    XDG_DATA_HOME = config.xdg.dataHome;
                    XDG_STATE_HOME = config.xdg.stateHome;
                    PATH = lib.concatStringsSep ":" [
                      "${config.home.profileDirectory}/bin"
                      "/run/current-system/sw/bin"
                      "/opt/homebrew/bin"
                      "/usr/local/bin"
                      "/usr/bin"
                      "/bin"
                      "/usr/sbin"
                      "/sbin"
                    ];
                  };
                };
              });
          })
        )
      ]
    );
  };

  # General enable settings
  flake.modules.homeManager.sidepulse-settings = {
    lib,
    options,
    pkgs,
    ...
  }: {
    key = "sidepulse-settings#homeManager";
    config = lib.optionalAttrs (options.programs ? sidepulse) {
      programs.sidepulse = {
        enable = true;
        package = pkgs.local.sidepulse;
      };
    };
  };

  # Agent integration
  flake.modules.homeManager.sidepulse-claude = {
    lib,
    config,
    ...
  }: {
    key = "sidepulse-claude#homeManager";
    config = let
      sidepulseBin =
        if ((config.programs.sidepulse.package or null) != null)
        then (lib.getExe config.programs.sidepulse.package)
        else "${config.home.homeDirectory}/.local/bin/sidepulse";
      sidepulseLogJson =
        if ((config.programs.sidepulse.logDirectory or null) != null)
        then "${config.programs.sidepulse.logDirectory}/claude.jsonl"
        else "${config.xdg.stateHome}/sidepulse/agent-monitor/claude.jsonl";
    in {
      # Claude code hooks
      programs.claude-code.settings.hooks =
        lib.genAttrs
        [
          "SessionStart"
          "UserPromptSubmit"
          "PreToolUse"
          "PostToolUse"
          "PostToolUseFailure"
          "PermissionRequest"
          "Notification"
          "PreCompact"
          "PostCompact"
          "SubagentStop"
          "Stop"
          "SessionEnd"
        ]
        (
          _: [
            {
              matcher = "*";
              hooks = [
                {
                  type = "command";
                  command = ''
                    ${sidepulseBin} hook-log \
                      --provider claude \
                      --log "${sidepulseLogJson}" ; true
                  '';
                }
              ];
            }
          ]
        );
    };
  };
}
