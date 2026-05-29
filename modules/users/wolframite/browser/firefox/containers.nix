# Configuring firefox preferences
{...}: {
  flake.modules.homeManager.wolframite = {...}: {
    programs.firefox.profiles.wolframite.containers = {
      work = {
        name = "Work";
        id = 1;
        icon = "briefcase";
        color = "blue";
      };
      banking = {
        name = "Banking";
        id = 2;
        icon = "dollar";
        color = "green";
      };
      porn = {
        name = "Explicit";
        id = 3;
        icon = "pet";
        color = "red";
      };
    };
  };
}
