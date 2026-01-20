{ pkgs, ... }:
{
  users.users.borba = {
    isNormalUser = true;
    description = "BORBA JR W";
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "libvirtd"
      "dialout"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "borba" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
