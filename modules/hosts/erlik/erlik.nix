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
      # TODO: Pull these to user implementation side
      # Pick which directories get synced
      mediaDirs = {
        android.sync = {
          enable = true;
        };
        documents.sync = {
          enable = true;
        };
        download.sync = {
          enable = false;
        };
        music.sync = {
          enable = true;
        };
        pictures.sync = {
          enable = true;
        };
        projects.sync = {
          enable = false;
        };
        videos.sync = {
          enable = true;
        };
        work.sync = {
          enable = false;
        };
      };
    };
  };
}
