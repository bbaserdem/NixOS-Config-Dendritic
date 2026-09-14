# Add nixos mcp
{...}: {
  flake.modules.homeManager.llm-mcp-nixos = {pkgs, ...}: {
    # Add to global mcp servers
    programs.mcp.servers.mcp-nixos = {
      enabled = true;
      command = "${pkgs.unstable.mcp-nixos}/bin/mcp-nixos";
    };
  };
}
