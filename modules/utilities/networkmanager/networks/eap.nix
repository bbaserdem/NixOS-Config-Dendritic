# WPA-EAP PEAP/MSCHAPv2 template
{...}: {
  localConfig.network-manager.templates.eap = {
    requiredFields = [
      "ssid"
      "identity"
      "password"
    ];

    envFields = [
      "ssid"
      "identity"
      "password"
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
        key-mgmt = "wpa-eap";
      };

      "802-1x" = {
        eap = "peap;";
        identity = env "identity";
        phase2-auth = "mschapv2";
        password = env "password";
      };

      ipv4.method = "auto";

      ipv6 = {
        method = "auto";
        addr-gen-mode = "default";
      };
    };
  };
}
