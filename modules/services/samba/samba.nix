# Samba: file sharing
{...}: {
  flake.modules.nixos.samba = {...}: {
    services = {
      samba = {
        enable = true;
        openFirewall = true;

        settings = {
          # Global settings
          global = {
            workgroup = "WORKGROUP";
            "server string" = "%h";
            "map to guest" = "Bad User";
            "server role" = "standalone server";
          };
        };
      };
      # Advertise our samba to  windows as well
      samba-wsdd = {
        enable = true;
        openFirewall = true;
      };
    };
  };
}
