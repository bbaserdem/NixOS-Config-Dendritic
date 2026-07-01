# WPA-PSK template
{...}: {
  localConfig.network-manager.templates.wpa = {
    requiredFields = [
      "ssid"
      "psk"
    ];

    envFields = [
      "ssid"
      "psk"
    ];

    profile = {
      env,
      profileId,
      ...
    }: {
      connection = {
        id = profileId;
        type = "wifi";
        permissions = "";
        autoconnect = true;
      };

      wifi = {
        mode = "infrastructure";
        ssid = env "ssid";
      };

      wifi-security = {
        auth-alg = "open";
        key-mgmt = "wpa-psk";
        psk = env "psk";
      };

      ipv4.method = "auto";

      ipv6 = {
        method = "auto";
        addr-gen-mode = "default";
      };
    };
  };
}
