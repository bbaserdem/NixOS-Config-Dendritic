# Add codegraph as global mcp tool
{
  den,
  inputs,
  ...
}: {
  den = {
    aspects.development = {
      provides.agents = {
        # Auto-enable when agents are dispatched
        includes = [
          den.aspects.development._.agents._.codegraph
        ];
        # Aspect config
        provides.codegraph = {
          name = "development/agents/codegraph";
          provides.to-users = {
            user,
            host,
          }: {
            name = "development/agents/codegraph(${user.userName}@${host.name})";
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.agents-codegraph
              ];
            };
          };
        };
      };
    };
  };

  flake.modules.homeManager.agents-codegraph = {pkgs, ...}: {
    key = "agents-codegraph#homeManager";
    config = {
      # Install to user profile so it's available everywhere
      home.packages = with pkgs; [
        llm-agents.codegraph
      ];

      # Add to global mcp servers
      programs.mcp.servers.codegraph = {
        type = "stdio";
        command = "${pkgs.llm-agents.codegraph}/bin/codegraph";
        enabled = true;
        args = [
          "serve"
          "--mcp"
        ];
      };

      # Specific hooks for software
      # Give claude permissions
      programs.claude-code.settings = {
        permissions = {
          allow = [
            "mcp__codegraph__*"
          ];
        };
      };
    };
  };
}
