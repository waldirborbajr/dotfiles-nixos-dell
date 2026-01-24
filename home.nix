# home.nix
{ config, pkgs, ... }:

{
  # Obrigatório: versão do state (use a do seu nixpkgs)
  home.stateVersion = "25.11";

  # Nome do usuário e home (deve bater com o seu)
  home.username = "waldir";               # ← mude para o seu username real
  home.homeDirectory = "/home/waldir";    # ou "/home/<seu-user>"

  # Teste simples: ativa fzf com integração zsh (é o que você quer!)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Pacotes só para o seu usuário (opcional, pode mover coisas daqui do systemPackages)
  home.packages = with pkgs; [
    # zoxide eza bat ripgrep fd tree  # ← exemplo, tire se já tem no system
  ];

  # Aqui no futuro você migra seu zsh completo
  # programs.zsh = { ... };
}
