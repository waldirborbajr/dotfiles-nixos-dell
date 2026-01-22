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

    nixosConfigurations = {
      macbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./core.nix
          ./hosts/macbook.nix
        ];
      };

      dell = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./core.nix
          ./hosts/dell.nix
        ];
      };
    };
  };
}
