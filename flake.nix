{
  description = "Multi-host NixOS flake for Borba";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }: {

    nixosConfigurations = {

      # ==========================================
      # MacBook host
      # ==========================================
      macbook = {
        system = "x86_64-linux";
        modules = [
          ./core.nix
          ./hosts/macbook.nix
        ];
      };

      # ==========================================
      # Dell host
      # ==========================================
      dell = {
        system = "x86_64-linux";
        modules = [
          ./core.nix
          ./hosts/dell.nix
        ];
      };

    };
  };
}
