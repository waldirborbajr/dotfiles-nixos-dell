# flake.nix
# ---
{
  description = "BORBA JR W - Multi-host NixOS Flake";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, ... }:
  let
    system = "x86_64-linux";

    # pkgs stable (base do sistema)
    pkgsStable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    # pkgs unstable (para uso pontual via pkgs.unstable)
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # overlay para expor pkgs.unstable
    unstableOverlay = final: prev: {
      unstable = pkgsUnstable;
    };

    # Feature flags (require --impure to read env)
    devopsEnabled = builtins.getEnv "DEVOPS" == "1";
    qemuEnabled = builtins.getEnv "QEMU" == "1";
  in
  {
    # Enables: nix fmt
    formatter.${system} = pkgsStable.nixpkgs-fmt;

    nixosConfigurations = {
      macbook = nixpkgs-stable.lib.nixosSystem {
        inherit system;

        # Pass flags into modules (used by modules/features/*.nix)
        specialArgs = {
          inherit devopsEnabled qemuEnabled;
        };

        modules = [
          ({ ... }: { nixpkgs.overlays = [ unstableOverlay ]; })
          ./core.nix
          ./hosts/macbook.nix
        ];
      };

      dell = nixpkgs-stable.lib.nixosSystem {
        inherit system;

        # Pass flags into modules (used by modules/features/*.nix)
        specialArgs = {
          inherit devopsEnabled qemuEnabled;
        };

        modules = [
          ({ ... }: { nixpkgs.overlays = [ unstableOverlay ]; })
          ./core.nix
          ./hosts/dell.nix
        ];
      };
    };
  };
}