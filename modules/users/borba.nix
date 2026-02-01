# modules/users/borba.nix
# ---
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
    ## Relation Truth
    #openssh.authorizedKeys.keys = [
    # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... borba@laptop"
    #];
  };

  # Novo: define o grupo primário (resolve o erro atual)
  users.groups.borba = { };

  # Opcional: associa explicitamente o grupo ao usuário (boa prática)
  users.users.borba.group = "borba";

  ############################################
  # Security-impact-free kernel tweaks
  ############################################
  security.sudo.wheelNeedsPassword = false;
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
