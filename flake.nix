{
  description = "BORBA JR W - Multi-host NixOS Flake for MacBook & Dell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }: {

    # Função que retorna uma configuração NixOS para um host específico
    nixosConfigurations = let
      systemPkgs = nixpkgs.legacyPackages.x86_64-linux;
      makeConfig = hostName: {
        # Base do sistema
        imports = [
          ./core.nix
          ./hosts/${hostName}.nix
        ];
        system.stateVersion = "25.11";
      };
    in {
      macbook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ makeConfig "macbook" ];
      };

      dell = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ makeConfig "dell" ];
      };
    };
  };
}
