# Configuring vcs for users
# Provide settings for;
# - git
# - jj
{inputs, ...}: {
  flake.modules.homeManager.vcs = {...}: {
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
