# Su-ana disko config
{inputs, ...}: {
  flake = {
    modules.nixos.yel-ana = {...}: {
      # Import the declared disk layout
      imports = [
        inputs.self.diskoConfigurations.yel-ana
      ];

      # Crypttab setup
      environment.etc.crypttab.text = ''
        # Configuration for encrypted block devices.
        # See crypttab(5) for details.

        # Put the keyfiles needed in /run/cryptsetup-keys.d/<name>.key

        # <name>            <device>                            <password>  <options>
        Yel-Ana_Data        PARTLABEL=Crypt_Yel-Ana_Data        -           luks,timeout=180
      '';

      # Extra fstab entries for filesystem ordering
      # fileSystems."/home/wolframite".depends = ["/home"];

      # Sops secrets for key-file provisioning
      sops.secrets = {
        crypt-data = {
          sopsFile = inputs.self + /secrets/host/yel-ana/Yel-Ana_Data.key;
          format = "binary";
          path = "/run/cryptsetup-keys.d/Yel-Ana_Data.key";
        };
      };
    };

    # Disk setup
    diskoConfigurations.yel-ana = {
      disko.devices.disk = {
        # Main disk on yel-ana laptop
        Linux = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-CT4000P3PSSD8_2325E6E7A223";
          content = {
            type = "gpt";
            partitions = {
              # System partitions

              # 1 - EFi System partition
              ESP = {
                size = "1G";
                label = "Yel-Ana_ESP";
                type = "EF00";
                priority = 100;
                content = {
                  type = "filesystem";
                  format = "vfat";
                  extraArgs = ["-n" "ESP"];
                  mountpoint = "/boot";
                  mountOptions = ["defaults"];
                };
              };

              # 2 - OS Partition, with BTRFS subvolumes
              Crypt_Linux = {
                size = "350G";
                label = "Crypt_Yel-Ana_Linux";
                priority = 1000;
                # LUKS encryption
                content = {
                  type = "luks";
                  name = "Yel-Ana_Linux";
                  initrdUnlock = true;
                  passwordFile = "/tmp/Yel-Ana.key";
                  additionalKeyFiles = [
                    "/tmp/Yel-Ana_Linux.key"
                  ];
                  extraFormatArgs = ["--label" "Crypt_Yel-Ana_Linux"];
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    # BTRFS system layout
                    type = "btrfs";
                    extraArgs = ["--force" "--label" "Yel-Ana_Linux"];
                    subvolumes = {
                      "/@nixos-root" = {
                        mountpoint = "/";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/@nixos-store" = {
                        mountpoint = "/nix";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/@nixos-persist" = {
                        mountpoint = "/persist";
                        mountOptions = ["compress=zstd" "strictatime" "lazytime"];
                      };
                      "/@nixos-log" = {
                        mountpoint = "/var/log";
                        mountOptions = ["compress=zstd" "strictatime" "lazytime"];
                      };
                      "/@nixos-machines" = {
                        mountpoint = "/var/lib/machines";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/@nixos-portables" = {
                        mountpoint = "/var/lib/portables";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/@nixos-swap" = {
                        mountpoint = "/swap";
                        mountOptions = ["noatime"];
                        swap.swapfile.size = "32G";
                      };
                      "/@user-wolframite" = {
                        mountpoint = "/home/wolframite";
                        mountOptions = ["compress=zstd" "strictatime" "lazytime"];
                      };
                    };
                    mountpoint = "/mnt/filesystem";
                    mountOptions = [
                      "compress=zstd"
                      "lazytime"
                      "strictatime"
                    ];
                  };
                };
              };

              # 3 - Data partition, ext4 at /home
              Crypt_Data = {
                size = "100%";
                label = "Crypt_Yel-Ana_Data";
                priority = 2000;
                # LUKS encryption
                content = {
                  type = "luks";
                  name = "Yel-Ana_Data";
                  initrdUnlock = false;
                  passwordFile = "/tmp/Yel-Ana_Data.key";
                  additionalKeyFiles = ["/tmp/Yel-Ana_Data.key"];
                  extraFormatArgs = ["--label" "Crypt_Yel-Ana_Data"];
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    extraArgs = ["-L" "Yel-Ana_Data"];
                    mountpoint = "/home";
                  };
                };
              };

              # End of the main disk
            };
          };
        };
      };
    };
  };
}
