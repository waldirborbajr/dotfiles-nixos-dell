{ pkgs, ... }:

{
  ############################################
  # User: borba
  ############################################
  users.users.borba = {
    isNormalUser = true;
    description = "BORBA JR W";

    # Shell padrão do usuário
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "libvirtd"    
       "dialout"   # required for CHIRP / serial radios
    ];
  };

  ############################################
  # Auto-login
  ############################################
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };

  ############################################
  # Disable TTY competition
  ############################################
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  ############################################
  # Passwordless sudo
  ############################################
  security.sudo.extraRules = [
    {
      users = [ "borba" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
