# modules/apps/git.nix
{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    userName  = "Waldir Borba Junior";
    userEmail = "wborbajr@gmail.com";

    extraConfig = {
      core.editor      = "nvim";
      core.pager       = "bat";
      core.autocrlf    = "input";

      init.defaultBranch = "main";

      pull.rebase = true;

      push.default         = "current";
      push.autoSetupRemote = true;

      fetch.prune     = true;
      fetch.pruneTags = true;

      rebase.autoStash  = true;
      rebase.autoSquash = true;

      merge.conflictStyle = "zdiff3";

      alias = {
        st  = "status --short --branch";
        co  = "checkout";
        br  = "branch -v";
        ci  = "commit";
        cm  = "commit -m";
        ca  = "commit --amend";
        lg  = "log --graph --oneline --decorate --all";
        df  = "diff --color-words";
        ds  = "diff --staged";
        fp  = "fetch --prune --prune-tags";
        pu  = "push --set-upstream origin HEAD";
        rh  = "reset --hard HEAD";
        undo = "reset --soft HEAD~1";
      };
    };

    ignores = [
      "*.swp" "*.swo" "*.swn" ".DS_Store"
      ".venv/" "venv/" "node_modules/"
      ".terraform/" "*.tfstate*" ".direnv/" ".envrc"
      "*.log" "*.tmp" "*.bak" "tags" "TAGS"
    ];
  };

  environment.systemPackages = with pkgs; [ git git-lfs delta tig ];
}
