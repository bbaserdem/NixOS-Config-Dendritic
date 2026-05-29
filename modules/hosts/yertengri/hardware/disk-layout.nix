# Su-ana disko config
{inputs, ...}: {
  flake.diskoConfigurations.yertengri = {
    disko.devices.disk = {
      # Main disk on yertengri PC
      Linux = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_PRO_512GB_S463NF0M531040W";
        content = {
          type = "gpt";
          partitions = {
            # System partitions

            # 1 - EFi System partition
            ESP = {
              size = "1G";
              label = "Yertengri_ESP";
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

            # 2 - OS Partition, fill with BTRFS subvolumes
            Crypt_Linux = {
              size = "100%";
              label = "Crypt_Yertengri_Linux";
              priority = 1000;
              # LUKS encryption
              content = {
                type = "luks";
                name = "Yertengri_Linux";
                initrdUnlock = true;
                passwordFile = "/tmp/Yertengri.key";
                additionalKeyFiles = [
                  "/tmp/Yertengri_Linux.key"
                ];
                extraFormatArgs = ["--label" "Crypt_Yertengri_Linux"];
                settings = {
                  allowDiscards = true;
                };
                content = {
                  # BTRFS system layout
                  type = "btrfs";
                  extraArgs = ["--force" "--label" "Yertengri_Linux"];
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
                    "/@user-joeysaur" = {
                      mountpoint = "/home/joeysaur";
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

      # The large data storage disk
      Data = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNW020T8_PHNH922200QG2P0C";
        content = {
          type = "gpt";
          partitions = {
            # This is for the LUKS space
            Crypt = {
              size = "100%";
              label = "Crypt_Yertengri_Data";
              content = {
                type = "luks";
                name = "Yertengri_Data";
                initrdUnlock = false;
                passwordFile = "/tmp/Yertengri.key";
                additionalKeyFiles = ["/tmp/Yertengri_Data.key"];
                extraFormatArgs = ["--label" "Crypt_Yertengri_Data"];
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  extraArgs = ["-L" "Yertengri_Data"];
                  mountpoint = "/home";
                };
              };
            };
          };
        };
      };

      # Another hard drive, holds work, and maybe a windows OS
      Work = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SHGP31-2000GM_ASB4N718111004R5E";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512G";
              label = "System";
              priority = 100;
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
              };
            };
            MSR = {
              size = "16M";
              label = "Microsoft reserved";
              priority = 501;
              type = "0C01";
            };
            Windows = {
              size = "150G";
              label = "Microsoft basic data";
              priority = 502;
              type = "0700";
            };
            Recovery = {
              size = "512M";
              label = "Windows RE";
              priority = 503;
              type = "2700";
            };
            Crypt = {
              size = "100%";
              label = "Crypt_Yertengri_Work";
              priority = 1000;
              content = {
                type = "luks";
                name = "Yertengri_Work";
                initrdUnlock = false;
                passwordFile = "/tmp/Yertengri.key";
                additionalKeyFiles = ["/tmp/Yertengri_Work.key"];
                extraFormatArgs = ["--label" "Crypt_Yertengri_Work"];
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  extraArgs = ["-L" "Yertengri_Work"];
                  mountpoint = "/home/work";
                };
              };
            };
          };
        };
      };
    };
  };
}
