# Configuring vcs systems personally
{...}: {
  flake.modules.homeManager.wolframite = {...}: {
    programs = {
      # Git user
      git.settings.user.name = "Batuhan Başerdem";
      git.settings.user.email = "baserdemb@gmail.com";

      # Jujutsu
      jujutsu.settings.user.name = "Batuhan Başerdem";
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
