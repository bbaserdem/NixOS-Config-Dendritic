# Configuring firefox containers
{...}: {
  flake.modules.home-manager.firefox = {...}: {
    programs.firefox.profiles.default.containers = {
      work = {
        name = "Work";
        id = 1;
        icon = "briefcase";
        color = "blue";
      };
      banking = {
        name = "Finance";
        id = 2;
        icon = "dollar";
        color = "green";
      };
      explicit = {
        name = "Adult";
        id = 3;
        icon = "pet";
        color = "red";
      };
    };
  };
}
