# modules/system/default.nix
# System-level modules aggregator with individual enable options
{ config, lib, ... }:

{
  imports = [
    ./nixpkgs.nix
    ./base.nix
    ./networking.nix
    ./audio.nix
    ./fonts.nix
    ./ssh.nix
    ./system-packages.nix
    ./serial-devices.nix
    ./no-sleep.nix
  ];

  options.system-config = {
    base = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable base system configuration (timezone, locale, nix features)";
      };
    };

    networking = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable NetworkManager and networking services";
      };
    };

    audio = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable PipeWire audio stack";
      };
    };

    fonts = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable system fonts and fontconfig";
      };
    };

    ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable OpenSSH server";
      };
    };

    systemPackages = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable system-wide packages";
      };
    };

    serialDevices = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable serial device support (for ham radio, etc)";
      };
    };

    noSleep = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Disable sleep, suspend, and hibernate";
      };
    };
  };
}
