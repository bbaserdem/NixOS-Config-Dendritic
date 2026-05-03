# Configuring vcs systems personally
{...}: {
  flake.modules.homeManager.batuhan = {...}: {
    programs = {
      # Git user
      git.settings.user.name = "Batuhan Baserdem";
      git.settings.user.email = "baserdemb@gmail.com";

      # Jujutsu
      jujutsu.settings.user.name = "Batuhan Baserdem";
      jujutsu.settings.user.email = "baserdemb@gmail.com";

      # GH account
      gh = {
        settings = {
          prompt = "enabled";
          prefer_editor_prompt = "disabled";
          color_labels = "enabled";
          spinner = "enabled";
        };
        hosts = {
          "github.com" = {
            git_protocol = "ssh";
            users = {
              bbaserdem = "";
            };
            user = "bbaserdem";
          };
        };
      };
    };
  };
}
