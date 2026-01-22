{
  description = "BORBA JR W - Multi-host NixOS Flake";

  inputs = {
    # Stable Nixpkgs versão 25.11
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Nixpkgs unstable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Utiliza flake-utils para suporte a múltiplos sistemas
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, flake-utils, ... }:

    # Usa flake-utils para lidar com múltiplos sistemas
    flake-utils.lib.eachSystem (system: let
      # Definindo qual versão do nixpkgs utilizar (stable ou unstable)
      nixpkgs = if system == "x86_64-linux" then nixpkgs-stable else nixpkgs-unstable;

      # Aqui, criamos um overlay para garantir que a versão certa do nixpkgs seja usada
      overlays = [
        (final: prev: {
          nixpkgs-stable = nixpkgs-stable;
          nixpkgs-unstable = nixpkgs-unstable;
        })
      ];
    in {
      # Configurações para os hosts
      nixosConfigurations = {

        # ==========================================
        # MacBook host
        # ==========================================
        macbook = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit nixpkgs overlays system;
          };
          modules = [
            ./core.nix
            ./hosts/macbook.nix
          ];

          # Systemd-boot configuration (aplicada apenas para este host)
          boot.loader.systemd-boot.configurationLimit = 10;
          boot.loader.systemd-boot.enable = true;
          boot.loader.grub.enable = false;  # Desabilitando GRUB para usar systemd-boot
          boot.rollback.enable = true;      # Habilitando rollback de configurações
        };

        # ==========================================
        # Dell host
        # ==========================================
        dell = nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = {
            inherit nixpkgs overlays system;
          };
          modules = [
            ./core.nix
            ./hosts/dell.nix
          ];

          # Systemd-boot configuration (aplicada apenas para este host)
          boot.loader.systemd-boot.configurationLimit = 10;
          boot.loader.systemd-boot.enable = true;
          boot.loader.grub.enable = false;  # Desabilitando GRUB para usar systemd-boot
          boot.rollback.enable = true;      # Habilitando rollback de configurações
        };
      };
    });
}
