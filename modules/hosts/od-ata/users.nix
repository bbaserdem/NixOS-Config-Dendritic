# Od-ata system configuration
{...}: {
  den = {
    hosts.od-ata = {
      primaryUser = "wolframite";
      # Users
      users.wolframite = {
        classes = [
          "admin"
          "homeManager"
          "user"
        ];
        syncthing = {
          enable = true;
          id = "SURUPHR-XMRJVSZ-4E2BL6S-KEAX4C4-LOMYYI4-KSPWQEZ-75ZQDS4-O4EIBA6";
        };
        usbAccess = true;
      };
    };
  };
}
