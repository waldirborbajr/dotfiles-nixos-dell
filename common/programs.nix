{ pkgs, ... }: {
  programs = {
    firefox.enable = true;

    zsh.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  # Default terminal
  xdg.mime.defaultApplications = {
    "application/x-terminal-emulator" = "alacritty.desktop";
  };
}