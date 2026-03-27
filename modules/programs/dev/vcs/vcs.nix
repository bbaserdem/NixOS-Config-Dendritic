# Configuring vcs for users
# Provide settings for;
# - git
# - jj
{inputs, ...}: {
  flake.modules.homeManager.vcs = {...}: {
    # VCS tools configuration

    # Import specific modules
    imports = with inputs.self.modules.homeManager; [
      jj
      git
    ];

    # Configure cross-tool integrations
    config = {
      programs = {
        delta = {
          enable = true;
          enableGitIntegration = true;
          enableJujutsuIntegration = true;
        };
      };
    };
  };
}
