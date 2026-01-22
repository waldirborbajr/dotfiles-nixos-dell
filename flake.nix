{
  description = "Multi-host NixOS flake for Borba";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }: {

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
