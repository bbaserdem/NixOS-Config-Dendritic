# Yertengri firmware setup
{den, ...}: {
  den = {
    hosts.yertengri = {
      boot.microcode = "amd";
    };

    aspects.yertengri = {
      # More firmware related settings
    };
  };
}
