# Initialize this user
{...}: {
  localConfig.users.wolframite = {
    admin = true;
    nixTrusted = true;
    steamShare = true;
    profile = {
      global = "wolframite_lensa";
      yel-ana = "wolframite_headshot";
    };
  };
}
