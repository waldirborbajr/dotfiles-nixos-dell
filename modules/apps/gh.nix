# modules/apps/gh.nix
{ config, pkgs, lib, ... }:

{
  programs.gh = {
    enable = true;

    # Configurações gerais + aliases (agora tudo dentro de settings para evitar warning)
    settings = {
      git_protocol = "ssh";          # default global (pode ser sobrescrito por host)
      editor = "";                     # vazio = usa $EDITOR (nvim)
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      pager = "";                      # vazio = usa $PAGER (bat se configurado)

      # Aliases expandidos para DevOps (agora aqui para silenciar o warning)
      aliases = {
        co        = "pr checkout";                        # checkout PR
        pv        = "pr view --web";                      # abre PR no browser
        pi        = "pr create --fill --web";             # cria PR preenchido + abre web
        il        = "issue list --limit 20";              # lista issues recentes
        ic        = "issue create --web";                 # cria issue no browser
        prm       = "pr merge --squash --delete-branch";  # merge squash + deleta branch
        prd       = "pr merge --delete-branch";           # merge default + deleta branch
        prr       = "pr ready";                           # marca PR como ready
        prc       = "pr checks";                          # mostra checks/CI do PR atual
        prs       = "pr status";                          # status de PRs/review requests
        repo      = "repo view --web";                    # abre repo no browser
        rcl       = "repo clone";                         # clona repo (gh repo clone org/repo)
        rl        = "release list";                       # lista releases
        rc        = "release create --generate-notes";    # cria release com notes automáticas
        rw        = "workflow list";                      # lista GitHub Actions workflows
        rwr       = "workflow run";                       # roda workflow manual
        auth      = "auth status";                        # status de autenticação
        who       = "api user --jq '.login'";             # mostra usuário atual logado
        prl       = "pr list --limit 20";                 # lista PRs recentes
        draft     = "pr create --draft --fill";           # cria PR draft
        review    = "pr review --approve";                # aprova PR atual
        "merge-auto" = "pr merge --auto --squash";        # merge automático quando pronto
      };
    };
  };

  # Pacotes relacionados
  home.packages = with pkgs; [
    gh
    gh-dash  # TUI bonito para PRs/issues (recomendado em DevOps)
  ];

  # Comentário: configuração de múltiplos hosts (github.com, gitlab.com) não é suportada diretamente
  # no home-manager. Faça manualmente uma única vez após o primeiro rebuild:
  #   gh auth login --hostname github.com
  #   gh auth login --hostname gitlab.com
  #   gh config set user omnicwbdev --host github.com
  #   gh config set user waldirborbajr --host gitlab.com
  # Depois disso o home-manager não mexe mais nesses arquivos.
}
