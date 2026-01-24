# home.nix
{ config, pkgs, lib, ... }:

{
  # Obrigatório: versão do state (use a do seu nixpkgs)
  home.stateVersion = "25.11";

  # Nome do usuário e home (deve bater com o seu)
  home.username = "waldir";  # ← confirme que é exatamente "waldir" (ou mude para o correto)
  home.homeDirectory = lib.mkForce "/home/waldir";  # ← FORÇA o valor correto, ignora /var/empty

  # Teste simples: ativa fzf com integração zsh (é o que você quer!)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 60%"
      "--layout=reverse"
      "--border"
      "--info=inline-right"
      "--ansi"
    ];
  };

  # Pacotes só para o seu usuário (adicione o que quiser mover do systemPackages)
  home.packages = with pkgs; [
    zoxide
    eza
    bat
    ripgrep
    fd
    tree
    # ... outros que você usava globalmente
  ];

  # Aqui no futuro migramos seu zsh completo
  # programs.zsh = { ... };
}
