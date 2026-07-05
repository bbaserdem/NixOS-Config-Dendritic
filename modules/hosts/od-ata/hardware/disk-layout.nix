# Od-Ata disko config
{inputs, ...}: let
  name = "od-ata";
  namePretty = "Od-Ata";
in {
  flake = {
    modules.nixos."${name}" = {...}: {
      # Import the declared disk layout
      imports = [
        inputs.self.diskoConfigurations.od-ata
      ];

      # Crypttab setup
      environment.etc.crypttab.text = ''
        # Configuration for encrypted block devices.
        # See crypttab(5) for details.

        # Put the keyfiles needed in /etc/cryptsetup-keys.d/<name>.key

        # <name>              <device>                            <password>  <options>
        ${namePretty}_Data    PARTLABEL=Crypt_${namePretty}_Data  -           luks,timeout=180
      '';
    };

    # Disk setup
    diskoConfigurations."${name}" = {
      disko.devices.disk = {
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
                label = "${namePretty}_ESP";
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
                label = "Crypt_${namePretty}_Swap";
                priority = 200;
                content = {
                  type = "luks";
                  name = "Od-Ata_Swap";
                  initrdUnlock = true;
                  passwordFile = "/tmp/${namePretty}.key";
                  additionalKeyFiles = [
                    "/tmp/${namePretty}_Swap.key"
                  ];
                  extraFormatArgs = ["--label" "Crypt_${namePretty}_Swap"];
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
                label = "Crypt_${namePretty}_Linux";
                priority = 1000;
                # LUKS encryption
                content = {
                  type = "luks";
                  name = "${namePretty}_Linux";
                  initrdUnlock = true;
                  passwordFile = "/tmp/${namePretty}.key";
                  additionalKeyFiles = [
                    "/tmp/${namePretty}_Linux.key"
                  ];
                  # enrollFido2 = false;
                  # enrollRecovery = false;
                  extraFormatArgs = ["--label" "Crypt_${namePretty}_Linux"];
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
                    extraArgs = ["--force" "--label" "${namePretty}_Linux"];
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

        # Data disk, 3.6TiB disk
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
                label = "Crypt_${namePretty}_Data";
                priority = 2000;
                # LUKS encryption
                content = {
                  type = "luks";
                  name = "${namePretty}_Data";
                  initrdUnlock = false;
                  passwordFile = "/tmp/${namePretty}.key";
                  additionalKeyFiles = ["/tmp/${namePretty}_Data.key"];
                  extraFormatArgs = ["--label" "Crypt_${namePretty}_Data"];
                  # enrollFido2 = false;
                  # enrollRecovery = false;
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    extraArgs = ["-L" "${namePretty}_Data"];
                    mountpoint = "/home";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
