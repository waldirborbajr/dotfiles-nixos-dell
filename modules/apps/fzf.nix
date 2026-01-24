# modules/apps/fzf.nix
{ config, pkgs, lib, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;          # ← isso ativa Ctrl+R, Ctrl+T e Alt+C no zsh

    # Opcional: suas preferências de visual / comportamento
    defaultOptions = [
      "--info=inline-right"
      "--ansi"
      "--layout=reverse"
      "--border=rounded"
      "--height=60%"
      "--preview-window=down:70%"
      "--color=bg+:#2d2d2d,fg+:#ffffff,hl+:#ffcc00,pointer:#ffcc00"
      # ... adicione mais se quiser
    ];

    # Opcional: mude o comando de arquivos se quiser algo mais rápido / custom
    # fileWidgetCommand = "fd --type f --hidden --exclude .git";
    # fileWidgetOptions = [ "--preview 'bat --color=always {}'" ];

    # historyWidgetOptions = [ "--sort" ];  # ou "--exact" etc se quiser
  };

  # Se quiser garantir que o fzf esteja disponível mesmo sem o programs.fzf
  # (geralmente não precisa, pois enable = true já instala)
  home.packages = [ pkgs.fzf ];
}
