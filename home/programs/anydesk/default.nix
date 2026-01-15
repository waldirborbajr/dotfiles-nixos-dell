{ config, pkgs, ... }:

{
  # Instala o AnyDesk via home-manager (pacote do nixpkgs)
  home.packages = with pkgs; [
    anydesk
  ];

  # Opcional: variáveis de ambiente ou PATH extras se precisar
  # (AnyDesk geralmente não precisa, mas para consistência com Go/Rust)
  home.sessionPath = [
    # Se quiser adicionar algum bin extra custom do AnyDesk, mas não é necessário
  ];

  # Opcional: ativação para garantir que o AnyDesk rode configurações iniciais
  # ou crie configurações de usuário (ex: ID fixo, senha) via script
  # Isso roda na primeira ativação ou quando mudar
  home.activation = {
    ensureAnydeskSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      # Exemplo: cria diretório de config se não existir
      mkdir -p "${config.home.homeDirectory}/.anydesk"

      # Opcional: você pode adicionar configs iniciais aqui via echo ou substituição
      # Ex: definir senha não-interativa (use com cuidado, melhor gerenciar manualmente)
      # echo "your_password_hash" > "${config.home.homeDirectory}/.anydesk/security.conf"
      # Mas recomendo configurar via interface gráfica na primeira execução
    '';
  };

  # Opcional: aliases úteis para o shell (adicione no seu programs.zsh se quiser)
  # programs.zsh.shellAliases = {
  #   ad     = "anydesk";
  #   ad-id  = "anydesk --get-id";
  #   ad-connect = "anydesk --connect";
  # };
}