# Erlik; den registry (no output yet)
{...}: {
  den.hosts.erlik = {
    system = "aarch64-linux";
    class = "droid";
    description = "Erlik: Android phone";

    users.wolframite = {
      syncthing = {
        # We sync; enable even without actionable behavior here
        enable = true;
        id = "DTELBJI-F7UOJXY-5DCXOKU-EL3DHZC-S7S7K4H-AFLV3KD-HBSNRUY-W6QOEQH";
        globalShare = true;
      };
    };
  };
}
