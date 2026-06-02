# Initialize this user
{...}: {
  localConfig.users.wolframite = {
    admin = true;
    nixTrusted = true;
    steamShare = true;
  };
}
