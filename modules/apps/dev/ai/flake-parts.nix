# Flake partsq inif modules
{
  inputs,
  config,
  lib,
  ...
}: {
  # Inputs to pull agents from
  flake-file = {
    nixConfig = {
      extra-substituters = [
        "https://cache.numtide.com"
      ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
    inputs.llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  # Apply our nixpkgs overlay to pull in from pkgs
  localConfig.nixpkgs.overlays = [
    inputs.llm-agents.overlays.default
  ];

  # Collect factoried modules
  flake.modules = lib.foldl lib.recursiveUpdate {} [
    (config.factory.inclusionModules "ai")
    (config.factory.inclusionModules "ai-claude")
    (config.factory.inclusionModules "ai-codex")
    (config.factory.inclusionModules "ai-opencode")
    (config.factory.inclusionModules "ai-droid")
    (config.factory.inclusionModules "ai-forgecode")
  ];
}
