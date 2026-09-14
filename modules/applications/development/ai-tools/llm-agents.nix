# External flake providing up to date agentic derivations
{inputs, ...}: {
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

  # Some global local config
  flake.modules.homeManager.llm-settings = {lib, ...}: {
    options = let
      linesToSpinnerList = l:
        l
        |> lib.splitString "\n"
        |> builtins.map lib.trim
        |> builtins.filter (l: l != "");
      typeToFile = f: inputs.self + "/assets/ai/spinners/${f}.txt";
    in {
      local.llm.spinners = lib.mkOption {
        default = null;
        type = lib.types.nullOr (lib.types.oneOf [
          (lib.types.listOf (lib.types.str))
          lib.types.lines
          lib.types.path
          lib.types.str
        ]);
        description = "Spinner verb list to replace builtin version";
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
      };
    };

    # Global config options
    config = {
      programs.mcp.enable = true;
    };
  };
}
