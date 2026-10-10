# Yertengri's disko configuration
{...}: {
  config = {
    den = {
      # Crypttab setup
      aspects.yertengri.nixos = {...}: {
        environment.etc.crypttab.text = ''
          # Configuration for encrypted block devices.
          # See crypttab(5) for details.

          # Put the keyfiles needed in /etc/cryptsetup-keys.d/<name>.key

          # <name>            <device>                            <password>  <options>
          Yertengri_Data      PARTLABEL=Crypt_Yertengri_Data      -           luks,timeout=180
          Yertengri_Work      PARTLABEL=Crypt_Yertengri_Work      -           luks,nofail,timeout=180
        '';
      };

      # Disko setup
      hosts.yertengri.disks.disk = {
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
                      "/@nixos_root" = {
                        mountpoint = "/";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/@nixos_store" = {
                        mountpoint = "/nix";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/@nixos_persist" = {
                        mountpoint = "/persist";
                        mountOptions = ["compress=zstd" "strictatime" "lazytime"];
                      };
                      "/@nixos_log" = {
                        mountpoint = "/var/log";
                        mountOptions = ["compress=zstd" "strictatime" "lazytime"];
                      };
                      "/@nixos_machines" = {
                        mountpoint = "/var/lib/machines";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/@nixos_portables" = {
                        mountpoint = "/var/lib/portables";
                        mountOptions = ["compress=zstd" "noatime"];
                      };
                      "/@nixos_swap" = {
                        mountpoint = "/swap";
                        mountOptions = ["noatime"];
                        swap.swapfile.size = "32G";
                      };
                      "/@user_wolframite" = {
                        mountpoint = "/home/wolframite";
                        mountOptions = ["compress=zstd" "strictatime" "lazytime"];
                      };
                      "/@user_ben-abuyah" = {
                        mountpoint = "/home/ben-abuyah";
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

        # Another hard drive, holds extra storage space, and maybe a windows OS
        Extra = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-SHGP31-2000GM_ASB4N718111004R5E";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "512M";
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
                size = "1G";
                label = "Windows RE";
                priority = 503;
                type = "2700";
              };
              Crypt = {
                size = "100%";
                label = "Crypt_Yertengri_Extra";
                priority = 1000;
                content = {
                  type = "luks";
                  name = "Yertengri_Extra";
                  initrdUnlock = false;
                  passwordFile = "/tmp/Yertengri.key";
                  additionalKeyFiles = ["/tmp/Yertengri_Extra.key"];
                  extraFormatArgs = ["--label" "Crypt_Yertengri_Extra"];
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    extraArgs = ["-L" "Yertengri_Extra"];
                    mountpoint = "/mnt/extra";
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
