# flake.nix
# ---
{
  description = "BORBA JR W - Multi-host NixOS Flake";
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };
  outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }:
  let
    lib = nixpkgs-stable.lib;
    devopsEnabled = builtins.getEnv "DEVOPS" == "1";
    qemuEnabled = builtins.getEnv "QEMU" == "1";
    unstableOverlay = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    };
    nixpkgsConfig = {
      config.allowUnfree = true;
      overlays = [ unstableOverlay ];
    };
    mkHost = { hostname, system }:
      lib.nixosSystem {
        specialArgs = {
          inherit inputs devopsEnabled qemuEnabled;
        };
        modules = [
          ({ config, pkgs, lib, ... }: {
            nixpkgs.hostPlatform = system;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [ unstableOverlay ];
          })
          ./core.nix
          (./hosts + "/${hostname}.nix")
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs devopsEnabled qemuEnabled;
            };

            home-manager.users.borba = { pkgs, lib, ... }: {
              imports = [
                ./home.nix
                ./modules/apps/git.nix
              ];
            };
          }
        ];
      };
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  in
  {
    formatter = lib.genAttrs supportedSystems (system:
      (import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      }).nixpkgs-fmt
    );
    nixosConfigurations = {
      macbook = mkHost { hostname = "macbook"; system = "x86_64-linux"; };
      dell = mkHost { hostname = "dell"; system = "x86_64-linux"; };
    };
  };
}
