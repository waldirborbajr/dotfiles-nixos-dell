# modules/apps/fzf.nix
{ config, pkgs, lib, ... }:

{
  # Pacotes necessários para fzf + bons previews
  home.packages = with pkgs; [
    fzf
    fd          # mais rápido que find para Ctrl+T
    
    tree        # preview de diretórios no Alt+C
  ];

  # Variáveis de ambiente padrão do fzf (customizáveis)
  home.sessionVariables = {
    FZF_DEFAULT_OPTS = "--info=inline-right --ansi --layout=reverse --border=rounded --height=60%";
    
    # Comando base para Ctrl+T (arquivos) – usa fd se disponível
    FZF_CTRL_T_COMMAND = "fd --type f --hidden --follow --exclude .git || find . -type f";
    
    # Preview para Ctrl+T
    FZF_CTRL_T_OPTS = "--preview 'bat --color=always --style=numbers --line-range=:500 {}'";
    
    # Preview para Alt+C (cd para diretórios)
    FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200'";
  };

  # Opcional: aliases rápidos para quem usa fzf fora do shell
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    fzf-preview = "fzf --preview 'bat --color=always {}'";
    fzf-history = "history | fzf";
  };
}
