# Configuring vcs for users
# Provide settings for;
# - git
# - jj
{inputs, ...}: {
  flake.modules.home-manager.vcs = {...}: {
    # VCS tools configuration

    # Import specific modules
    imports = with inputs.self.modules.home-manager; [
      jj
      git
    ];

    # Configure cross-tool integration
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
