# core.nix
# Hub central: módulos globais / system-level comuns a todos os hosts
# - Não coloque aqui coisas user-level (zsh, git, gh, etc.) → vão no home-manager
{ ... }:
{
  imports = [
    # Sistema base (em modules/system/)
    ./modules/system/nixpkgs.nix
    ./modules/system/base.nix
    ./modules/system/networking.nix
    ./modules/system/audio.nix
    ./modules/system/fonts.nix
    ./modules/system/ssh.nix
    ./modules/system/system-packages.nix

    # Features on-demand (devops tools, qemu)
    ./modules/features/devops.nix
    ./modules/features/qemu.nix

    # Usuário principal
    ./modules/users/borba.nix

    # Languages (system-level)
    ./modules/languages/python.nix
    ./modules/languages/nodejs.nix

    # Flatpak + portal (system services)
    ./modules/apps/flatpak.nix
    ./modules/xdg-portal.nix
  ];
}
