# modules/apps/ripgrep.nix
# Advanced ripgrep configuration for DevOps workflows
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.ripgrep.enable {
    # ========================================
    # Ripgrep package
    # ========================================
    home.packages = with pkgs; [
      ripgrep
    ];

    # ========================================
    # Ripgrep configuration (via environment)
    # ========================================
    home.sessionVariables = {
      # Default ripgrep flags
      RIPGREP_CONFIG_PATH = "${config.home.homeDirectory}/.ripgreprc";
    };

    # ========================================
    # Advanced ripgrep config file
    # ========================================
    home.file.".ripgreprc" = {
      text = ''
        # ==========================================
        # Ripgrep Config - DevOps Optimized
        # ==========================================
      
        # Display settings
        --max-columns=150
        --max-columns-preview
        --colors=line:none
        --colors=line:style:bold
      
        # Search behavior
        --smart-case
        --hidden
      
        # DevOps: Ignore version control
        --glob=!.git/*
        --glob=!.gitignore
        --glob=!.gitattributes
        --glob=!.gitmodules
        --glob=!.hg/*
        --glob=!.svn/*
      
        # DevOps: Ignore build outputs
        --glob=!target/*
        --glob=!build/*
        --glob=!dist/*
        --glob=!out/*
        --glob=!bin/*
        --glob=!*.o
        --glob=!*.so
        --glob=!*.dylib
        --glob=!*.dll
        --glob=!*.exe
      
        # DevOps: Ignore dependencies (Node.js, Go, Rust, Python)
        --glob=!node_modules/*
        --glob=!vendor/*
        --glob=!.venv/*
        --glob=!venv/*
        --glob=!__pycache__/*
        --glob=!*.pyc
        --glob=!.pytest_cache/*
        --glob=!.tox/*
        --glob=!.cargo/*
        --glob=!Cargo.lock
      
        # DevOps: Ignore Terraform / IaC
        --glob=!.terraform/*
        --glob=!.terragrunt-cache/*
        --glob=!terraform.tfstate*
        --glob=!.terraform.lock.hcl
      
        # DevOps: Ignore Kubernetes / Docker
        --glob=!.kube/*
        --glob=!.docker/*
        --glob=!.minikube/*
        --glob=!.k3s/*
      
        # DevOps: Ignore CI/CD artifacts
        --glob=!.github/workflows/*.log
        --glob=!.gitlab-ci.log
        --glob=!.jenkins/*
        --glob=!.circleci/*
      
        # DevOps: Ignore logs and temp files
        --glob=!*.log
        --glob=!*.tmp
        --glob=!*.temp
        --glob=!*.swp
        --glob=!*.swo
        --glob=!*.swn
        --glob=!*~
        --glob=!.DS_Store
        --glob=!Thumbs.db
      
        # DevOps: Ignore package manager locks (except important ones)
        --glob=!package-lock.json
        --glob=!yarn.lock
        --glob=!pnpm-lock.yaml
        --glob=!poetry.lock
        --glob=!Pipfile.lock
        --glob=!Gemfile.lock
        --glob=!composer.lock
      
        # DevOps: Ignore IDE and editor files
        --glob=!.vscode/*
        --glob=!.idea/*
        --glob=!*.sublime-*
        --glob=!.code-workspace
        --glob=!.vim/*
        --glob=!.netrwhist
      
        # DevOps: Ignore OS and system files
        --glob=!.cache/*
        --glob=!.npm/*
        --glob=!.yarn/*
        --glob=!.pnpm-store/*
        --glob=!.local/share/*
      
        # DevOps: Ignore coverage reports
        --glob=!coverage/*
        --glob=!.coverage
        --glob=!htmlcov/*
        --glob=!.nyc_output/*
      
        # DevOps: Ignore documentation builds
        --glob=!docs/_build/*
        --glob=!site/*
        --glob=!.docusaurus/*
      
        # DevOps: Ignore Nix specific
        --glob=!result
        --glob=!result-*
        --glob=!.direnv/*
      
        # DevOps: Ignore compressed files (usually not text)
        --glob=!*.zip
        --glob=!*.tar
        --glob=!*.tar.gz
        --glob=!*.tgz
        --glob=!*.rar
        --glob=!*.7z
        --glob=!*.bz2
        --glob=!*.gz
        --glob=!*.xz
      
        # DevOps: Ignore binary/media files
        --glob=!*.png
        --glob=!*.jpg
        --glob=!*.jpeg
        --glob=!*.gif
        --glob=!*.ico
        --glob=!*.svg
        --glob=!*.pdf
        --glob=!*.woff
        --glob=!*.woff2
        --glob=!*.ttf
        --glob=!*.eot
      
        # Performance: Use multiple threads
        --threads=4
      
        # Advanced: Follow symlinks (be careful in CI/CD)
        # --follow
      
        # Advanced: Search compressed files (slow, commented by default)
        # --search-zip
      '';
    };

    # ========================================
    # Shell aliases for common DevOps patterns
    # ========================================
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      # Basic ripgrep aliases
      rg = "rg"; # Uses config from ~/.ripgreprc
      rgf = "rg --files"; # List files that would be searched
      rgl = "rg -l"; # Only show filenames with matches
      rgc = "rg -c"; # Count matches per file

      # DevOps specific searches
      rgenv = "rg --type-add 'env:*.{env,env.*}' -t env"; # Search .env files
      rgdocker = "rg --type-add 'docker:Dockerfile*,*.dockerfile,docker-compose*.{yml,yaml}' -t docker"; # Docker files
      rgk8s = "rg --type-add 'k8s:*.{yaml,yml}' --glob='*kube*' -t k8s"; # Kubernetes manifests
      rgtf = "rg --type-add 'tf:*.{tf,tfvars}' -t tf"; # Terraform files
      rgci = "rg --glob='.github/workflows/*' --glob='.gitlab-ci.yml' --glob='Jenkinsfile'"; # CI/CD configs

      # Search by language (common in DevOps)
      rggo = "rg -t go";
      rgrs = "rg -t rust";
      rgpy = "rg -t py";
      rgjs = "rg -t js";
      rgts = "rg -t ts";
      rgsh = "rg -t sh";
      rgyml = "rg -t yaml";
      rgtoml = "rg -t toml";
      rgjson = "rg -t json";

      # Inverted searches (find files WITHOUT pattern)
      rgi = "rg --files-without-match";

      # Case-sensitive search (override smart-case)
      rgs = "rg -s";

      # Search TODO/FIXME/HACK comments
      rgtodo = "rg '(TODO|FIXME|HACK|XXX|NOTE|BUG):'";

      # Search secrets/credentials patterns (security audit)
      rgsecrets = "rg -i '(password|secret|api[_-]?key|token|credential|auth)' --type-add 'code:*.{go,rs,py,js,ts,sh}' -t code";

      # Search for IPs and URLs
      rgip = "rg '\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b'";
      rgurl = "rg 'https?://[^\\s]+'";
    };
  };
}
