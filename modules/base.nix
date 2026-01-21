{ pkgs, ... }:
{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  programs.zsh.enable = true;

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  console.keyMap = "br-abnt2";

  ############################################
  # Infra aliases (NixOS lifecycle)
  ############################################

  environment.shellAliases = {
    nixgc   = "sudo nix-collect-garbage";
    garbage = "sudo nix-collect-garbage -d --delete-older-than 1d";

    switch  = "sudo nixos-rebuild switch";
    build   = "sudo nixos-rebuild switch -I nixos-config=$HOME/nixos-config";
    upgrade = "sudo nixos-rebuild switch --upgrade";
  };
    
}
