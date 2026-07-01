# Initialize this user
{...}: {
  localConfig.users.wolframite = {
    admin = true;
    nixTrusted = true;
    steamShare = true;
    nm-user = true;
    profile = {
      global = "wolframite_lensa";
      yel-ana = "wolframite_headshot";
    };
  };
}
