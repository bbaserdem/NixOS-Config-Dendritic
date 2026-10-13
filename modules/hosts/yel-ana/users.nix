# Su-ana users
{...}: {
  den = {
    hosts.yel-ana = {
      primaryUser = "wolframite";
      # The user
      users.wolframite = {
        # Wolframite user host-specific settings
        classes = [
          "admin"
          "homeManager"
          "user"
          "games"
        ];
        syncthing = {
          enable = true;
          id = "RBX3SWP-PGCGSXH-UKVCH74-ZM55W36-3M467UU-O64ZBXT-CTU5WMN-LSAJ5QR";
        };
        usbAccess = true;
        uinput = true;
        stt = {
          enable = true;
          osd.enable = false;
        };
      };
    };
  };
}
