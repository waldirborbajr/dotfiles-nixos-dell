# modules/apps/fastfetch.nix
# Fastfetch configuration - Modern system info tool
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.fastfetch.enable {
    # Instalar o fastfetch
    home.packages = with pkgs; [ fastfetch ];

    # Configuração customizada do fastfetch
    home.file.".config/fastfetch/config.jsonc".text = ''
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
          "source": "nixos",
          "padding": {
            "top": 1,
            "left": 2
          }
        },
        "display": {
          "separator": " → "
        },
        "modules": [
          {
            "type": "title",
            "format": "{user-name-colored}@{host-name-colored}"
          },
          {
            "type": "separator",
            "string": "─"
          },
          {
            "type": "os",
            "key": "OS",
            "keyColor": "cyan"
          },
          {
            "type": "kernel",
            "key": "Kernel",
            "keyColor": "cyan"
          },
          {
            "type": "uptime",
            "key": "Uptime",
            "keyColor": "cyan"
          },
          {
            "type": "packages",
            "key": "Packages",
            "keyColor": "cyan"
          },
          {
            "type": "shell",
            "key": "Shell",
            "keyColor": "cyan"
          },
          {
            "type": "terminal",
            "key": "Terminal",
            "keyColor": "cyan"
          },
          {
            "type": "terminalfont",
            "key": "Font",
            "keyColor": "cyan"
          },
          {
            "type": "de",
            "key": "DE",
            "keyColor": "cyan"
          },
          {
            "type": "wm",
            "key": "WM",
            "keyColor": "cyan"
          },
          {
            "type": "wmtheme",
            "key": "Theme",
            "keyColor": "cyan"
          },
          {
            "type": "separator",
            "string": "─"
          },
          {
            "type": "cpu",
            "key": "CPU",
            "keyColor": "green"
          },
          {
            "type": "gpu",
            "key": "GPU",
            "keyColor": "green"
          },
          {
            "type": "memory",
            "key": "Memory",
            "keyColor": "green"
          },
          {
            "type": "disk",
            "key": "Disk (/)",
            "keyColor": "green"
          },
          {
            "type": "battery",
            "key": "Battery",
            "keyColor": "green"
          },
          {
            "type": "separator",
            "string": "─"
          },
          {
            "type": "colors",
            "paddingLeft": 2
          }
        ]
      }
    '';
  };
}
