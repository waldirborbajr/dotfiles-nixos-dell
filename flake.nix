# flake.nix
{
  description = "BORBA JR W - Multi-host NixOS Flake";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, ... }:
  let
    lib = nixpkgs-stable.lib;

    # Feature flags (require --impure to read env)
    devopsEnabled = builtins.getEnv "DEVOPS" == "1";
    qemuEnabled   = builtins.getEnv "QEMU" == "1";

    # Overlay that exposes pkgs.unstable on the SAME system
    unstableOverlay = final: prev: {
      unstable = import nixpkgs-unstable {
        system = final.system;
        config.allowUnfree = true;
      };
    };

    # Common nixpkgs config (shared for all hosts)
    nixpkgsConfig = {
      config.allowUnfree = true;
      overlays = [ unstableOverlay ];
    };

    # Helper: build a host for any system (future-proof)
    mkHost = { hostname, system }:
      lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs devopsEnabled qemuEnabled;
        };

        modules = [
          ({ ... }: { nixpkgs = nixpkgsConfig; })
          ./core.nix
          (./hosts + "/${hostname}.nix")
        ];
      };
  in
  {
    # Enables: `nix fmt` (needs formatter.${system})
    formatter = lib.genAttrs
      [ "x86_64-linux" "aarch64-linux" ]
      (system:
        (import nixpkgs-stable { inherit system; config.allowUnfree = true; }).nixpkgs-fmt
      );

    nixosConfigurations = {
      macbook = mkHost { hostname = "macbook"; system = "x86_64-linux"; };
      dell    = mkHost { hostname = "dell";    system = "x86_64-linux"; };
    };
  };
}