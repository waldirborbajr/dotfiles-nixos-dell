{ config, pkgs, userConfig, ... }:

{
  home.username = "devops";
  home.homeDirectory = "/home/devops";
  home.stateVersion = "25.11";  # ou a mesma versão do seu sistema

  imports = [
    ../programs/git/default.nix
  ];

  # Pacotes específicos para DevOps – instale só para este usuário
  home.packages = with pkgs; [
    # Ferramentas core DevOps / infra
    ansible
    terraform
    terragrunt
    tflint
    tfsec          # ou checkov / trivy para security
    kubectl
    kubernetes-helm   # helm
    k9s               # UI para k8s
    fluxcd            # GitOps (se usar Flux)
    argocd            # se usar ArgoCD
    stern             # multi-pod logs
    kubectx
    kubelogin

    # Cloud CLIs
    awscli2
    google-cloud-sdk
    azure-cli

    # Containers / Orchestration
    docker-compose
    podman-compose   # se preferir podman
    dive             # analisar imagens Docker
    skopeo
    buildah          # se usar podman/buildah

    # CI/CD e git/tools
    git
    gh               # GitHub CLI
    git-crypt
    pre-commit
    act              # GitHub Actions local

    # Monitoring / observability
    prometheus
    grafana          # CLI tools
    jq               # essencial
    yq-go            # yaml processor
    httpie           # melhor que curl para APIs
    websocat

    # Nix/Dev extras úteis em DevOps
    nix-output-monitor  # nom para builds bonitos
    cachix
    direnv
    nix-direnv
  ];

  # Programas ativados só para este usuário
  programs = {
    zsh.enable = true;
    # Adicione aliases, plugins, etc. específicos de DevOps
    zsh.shellAliases = {
      k = "kubectl";
      kn = "k9s";
      tf = "terraform";
      tfa = "terraform apply";
      tfd = "terraform destroy";
      awswho = "aws sts get-caller-identity";
    };

    direnv.enable = true;
    direnv.nix-direnv.enable = true;  # cache nix-shell

    git = {
      enable = true;
      userName = "DevOps User";
      userEmail = "devops@empresa.com";  # ajuste
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

    # Outros: starship, zoxide, etc. se quiser um prompt bonito
    starship.enable = true;
    zoxide.enable = true;
    zoxide.enableZshIntegration = true;
  };

  # Variáveis de ambiente específicas
  home.sessionVariables = {
    KUBECONFIG = "$HOME/.kube/config";  # exemplo
    AWS_PROFILE = "default";            # ou use aws-vault/sso
  };

  # Dotfiles opcionais (ex: .zshrc extra, .terraformrc, etc.)
  # home.file.".zshrc".text = '' ... '';
}