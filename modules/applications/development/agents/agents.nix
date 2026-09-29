# External flake providing up to date agentic derivations
{
  inputs,
  den,
  lib,
  ...
}: {
  # Flake inputs
  flake-file = {
    inputs.llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-parts.follows = "flake-parts";
      };
    };
  };
  # Apply our nixpkgs overlay repo-wide to pull in from pkgs
  localConfig.nixpkgs.overlays = [
    inputs.llm-agents.overlays.shared-nixpkgs
  ];

  # Aspect config
  den = {
    schema = {
      # Host-schema
      host = {
        includes = [
          den.aspects.development.policies.agents-dispatch
        ];
        options = {
          development = lib.mkOption {
            type = lib.types.submodule {
              options = {
                agents = lib.mkOption {
                  description = "LLM Coding agent configuration";
                  default = {};
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        description = "Whether to install llm agents on this host.";
                        default = true;
                        type = lib.types.bool;
                      };
                      harnesses = lib.mkOption {
                        description = "Which harnesses to install on this host";
                        default = [
                          "opencode"
                          "pi"
                        ];
                        type = lib.types.listOf (lib.types.enum [
                          "opencode"
                          "pi"
                          "codex"
                          "claude"
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
      # User specific options
      user = {
        options = {
          agents = lib.mkOption {
            type = lib.types.submodule {
              options = {
                # User-based spinner list
                spinners = lib.mkOption (let
                  linesToSpinnerList = l:
                    l
                    |> lib.splitString "\n"
                    |> builtins.map lib.trim
                    |> builtins.filter (l: l != "");
                  typeToFile = f: inputs.self + "/assets/ai/spinners/${f}.txt";
                in {
                  description = "Spinner verb list to replace builtin versions";
                  default = null;
                  type = lib.types.nullOr (lib.types.oneOf [
                    (lib.types.listOf (lib.types.str))
                    lib.types.lines
                    lib.types.path
                    lib.types.str
                  ]);
                  apply = value:
                    if value == null
                    then null
                    else if builtins.isList value
                    then value
                    else if builtins.isString value
                    then
                      # Turn lines into a list
                      if lib.hasInfix "\n" value
                      then linesToSpinnerList value
                      else if builtins.pathExists value
                      then linesToSpinnerList (builtins.readFile value)
                      else if builtins.pathExists (typeToFile value)
                      then linesToSpinnerList (builtins.readFile (typeToFile value))
                      else throw "Invalid spinner-verb ${value}"
                    else throw "Invalid spinner-file";
                });
              };
            };
          };
        };
      };
    };

    # Aspect config
    aspects.development = {
      development.policies.agents-dispatch = {host, ...}:
        lib.optionals
        host.development.agents.enable
        (
          [
            (den.lib.policy.include den.aspects.development._.agents)
          ]
          ++ (
            # Also include all requested harnesses
            builtins.map
            (n: (den.lib.policy.include den.aspects.development._.agents._.${n}))
            host.development.agents.harnesses
          )
        );

      provides.agents = {
        name = "development/agents";
        provides.to-users = {
          user,
          host,
        }: {
          name = "development/agents(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.agents-settings
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.agents-settings = {pkgs, ...}: {
    key = "agents-settings#homeManager";
    # Global config options
    config = {
      # Enable mcp servers configuration; with some global servers that I use
      programs.mcp = {
        enable = true;
        servers = {
          # Nixos MCP should be generally available
          mcp-nixos = {
            enabled = true;
            command = "${pkgs.unstable.mcp-nixos}/bin/mcp-nixos";
          };
        };
      };
    };
  };
}
