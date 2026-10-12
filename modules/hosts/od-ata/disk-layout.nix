# Od-Ata disko config
{inputs, ...}: {
  # Module
  flake.modules.nixos.od-ata-disks = {...}: {
    key = "od-ata-disks#nixos";
    config = {
      environment.etc.crypttab.text = ''
        # Configuration for encrypted block devices.
        # See crypttab(5) for details.

        # Put the keyfiles needed in /etc/cryptsetup-keys.d/<name>.key

        # <name>        <device>                            <password>  <options>
        Od-Ata_Data     PARTLABEL=Crypt_Od-Ata_Data         -           luks,timeout=180
      '';
      zramSwap.enable = true;
    };
  };

  den = {
    aspects.od-ata.nixos = {...}: {
      imports = [
        inputs.self.modules.nixos.od-ata-disks
      ];
    };

    hosts.od-ata.disks.disk = {
      # Main disk on od-ata server; crucial SSD 931 GiB
      Linux = {
        type = "disk";
        device = "/dev/disk/by-id/ata-CT1000MX500SSD4_1903E1E45A59";
        content = {
          type = "gpt";
          partitions = {
            # System partitions

            # 1 - EFi System partition
            ESP = {
              size = "1G";
              label = "Od-Ata_ESP";
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

            # 2 - Encrypted swap partition
            Crypt_Swap = {
              size = "40G";
              label = "Crypt_Od-Ata_Swap";
              priority = 200;
              content = {
                type = "luks";
                name = "Od-Ata_Swap";
                initrdUnlock = true;
                passwordFile = "/tmp/Od-Ata.key";
                additionalKeyFiles = ["/tmp/Od-Ata_Swap.key"];
                extraFormatArgs = ["--label" "Crypt_Od-Ata_Swap"];
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    "password-cache=yes"
                  ];
                };
                content = {
                  type = "swap";
                  resumeDevice = true;
                  discardPolicy = "both";
                };
              };
            };

            # 3 - OS Partition, with BTRFS subvolumes
            Crypt_Linux = {
              size = "100%";
              label = "Crypt_Od-Ata_Linux";
              priority = 1000;
              # LUKS encryption
              content = {
                type = "luks";
                name = "Od-Ata_Linux";
                initrdUnlock = true;
                passwordFile = "/tmp/Od-Ata.key";
                additionalKeyFiles = ["/tmp/Od-Ata_Linux.key"];
                # enrollFido2 = false;
                # enrollRecovery = false;
                extraFormatArgs = ["--label" "Crypt_Od-Ata_Linux"];
                settings = {
                  allowDiscards = true;
                  # crypttabExtraOpts = [
                  #   "fido2-device=auto"
                  #   "token-timeout=10"
                  # ];
                };
                content = {
                  # BTRFS system layout
                  type = "btrfs";
                  extraArgs = ["--force" "--label" "Od-Ata_Linux"];
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
            # End of the main disk
          };
        };
      };

      # Large storage data disk, 3.6TiB disk
      Data = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SanDisk_SDSSDH3_4T00_2020A5800018";
        content = {
          type = "gpt";
          partitions = {
            # System partitions

            # 1 - Data partition
            Crypt_Data = {
              size = "100%";
              label = "Crypt_Od-Ata_Data";
              priority = 2000;
              # LUKS encryption
              content = {
                type = "luks";
                name = "Od-Ata_Data";
                initrdUnlock = false;
                passwordFile = "/tmp/Od-Ata.key";
                additionalKeyFiles = ["/tmp/Od-Ata_Data.key"];
                extraFormatArgs = ["--label" "Crypt_Od-Ata_Data"];
                # enrollFido2 = false;
                # enrollRecovery = false;
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  extraArgs = ["-L" "Od-Ata_Data"];
                  mountpoint = "/home";
                };
              };
            };
          };
        };
      };
    };
  };
}
