# Su-ana system configuration
{...}: {
  den = {
    hosts.su-ana = {
      primaryUser = "wolframite";

      users.wolframite = {
        classes = [
          "admin"
          "homeManager"
          "user"
          "containerization"
          "virtualization"
        ];
        syncthing = {
          enable = true;
          id = "AWRTUF4-MXSTBEU-C6MBBL6-3OXH3AM-OW3SR4K-CQKFXVA-GXHB3YU-X3EBEAH";
        };
      };
    };
  };
}
