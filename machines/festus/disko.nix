{ config, pkgs, ... }:
{

  # Clan vars:
  clan.core.vars.generators.disk-encryption = {
    files.password = {
      secret = true;
      neededFor = "partitioning";
    };
    runtimeInputs = [ pkgs.xkcdpass ];
    script = ''
      xkcdpass --numwords 6 --delimiter - --count 1 | tr -d "\n" > "$out"/password 
    '';
  };

  # Disk layout
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WDS500G1X0E-00AFY0_22127D801765_1";
        content = {
          type = "gpt";
          partitions = {

            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name  = "cryptroot";
                passwordFile = config.clan.core.vars.generators.disk-encryption.files.password.path;
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                  crypttabExtraOpts = [ "fido2-device=auto" ];
                };
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {

          swap = {
            size = "16G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };

          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" "-L" "nixos" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };

        };
      };
    };
  };
}
