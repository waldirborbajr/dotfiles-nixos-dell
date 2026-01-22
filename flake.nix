{
  description = "BORBA JR W - Multi-host NixOS Flake";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, flake-utils, ... }: flake-utils.lib.eachSystem
    (system: let
      nixpkgs = if system == "x86_64-linux" then nixpkgs-stable else nixpkgs-unstable;
    in {
      nixosConfigurations = {
        # ==========================================
        # MacBook host (continua com GNOME)
        # ==========================================
        macbook = nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            ./core.nix
            ./hosts/macbook.nix
          ];
        };

        # ==========================================
        # Dell host (i3 agora)
        # ==========================================
        dell = nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            ./core.nix
            ./hosts/dell.nix
            ./modules/performance/dell.nix  # Adicione o módulo de performance se necessário
          ];
        };
      };
    });
}
