# flake.nix
# ---
{
  description = "BORBA JR W - Multi-host NixOS Flake";
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (following nixpkgs-stable for compatibility)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Theme: Catppuccin (centralized)
    catppuccin.url = "github:catppuccin/nix";

    # Secrets management with SOPS
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # DevShells: Rust toolchains via fenix
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # DevShells: Helper for multiple systems
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, catppuccin, sops-nix, fenix, flake-utils, ... }:
    let
      lib = nixpkgs-stable.lib;
      # ==========================================
      # Feature flags (require --impure to read env)
      # ==========================================
      devopsEnabled = builtins.getEnv "DEVOPS" == "1";
      qemuEnabled = builtins.getEnv "QEMU" == "1";
      # ==========================================
      # Overlay: exposes pkgs.unstable for the SAME hostPlatform.system
      # Usage inside modules: pkgs.unstable.<pkg>
      # ==========================================
      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        };
      };
      # Common nixpkgs settings applied to all hosts
      nixpkgsConfig = {
        config.allowUnfree = true;
        overlays = [ unstableOverlay ];
      };
      # ==========================================
      # Host builder (future-proof; per-host system)
      # ==========================================
      mkHost = { hostname, system }:
        lib.nixosSystem {
          specialArgs = {
            inherit inputs devopsEnabled qemuEnabled hostname; # ← added hostname here
          };
          modules = [
            # Apply the system via module (recommended in 25.11+)
            ({ config, pkgs, lib, ... }: {
              nixpkgs.hostPlatform = system; # <-- This defines hostPlatform correctly
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ unstableOverlay ];
            })
            ./core.nix
            (./hosts + "/${hostname}.nix")

            # Theme: Catppuccin NixOS module
            catppuccin.nixosModules.catppuccin

            # Secrets: SOPS-nix module
            sops-nix.nixosModules.sops

            # New: import home-manager as a NixOS module
            home-manager.nixosModules.home-manager

            # Basic home-manager configuration
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs devopsEnabled qemuEnabled hostname; # ← added hostname here too
              };

              # Fix: correct user is "borba"
              home-manager.users.borba = { config, pkgs, lib, hostname, ... }: {
                # ← receives hostname
                imports = [
                  ./home.nix
                  # Theme: Catppuccin Home Manager module
                  catppuccin.homeModules.catppuccin
                  # Other modules can use hostname if needed
                ];
              };
            }
          ];
        };

      # Systems we care about (formatter + future machines)
      supportedSystems = [
        "x86_64-linux" # Intel/AMD PCs, most VMs
        "aarch64-linux" # Apple Silicon, Raspberry Pi (64-bit), ARM VMs
      ];
    in
    {
      # ==========================================
      # Enables: `nix fmt`
      # (nix fmt needs formatter.${system})
      # ==========================================
      formatter = lib.genAttrs supportedSystems (system:
        let
          pkgs = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        pkgs.treefmt.withConfig {
          runtimeInputs = with pkgs; [
            nixfmt
            prettier
            shfmt
          ];
          settings.formatter = {
            nixfmt = {
              command = "nixfmt";
              includes = [ "*.nix" ];
              options = [ "--indent=4" ];
            };
            prettier = {
              command = "prettier";
              includes = [ "*.md" "*.yaml" "*.yml" "*.json" ];
              options = [
                "--tab-width"
                "4"
              ];
            };
            shfmt = {
              command = "shfmt";
              includes = [ "*.sh" ];
              options = [ "-i" "4" "-ci" ];
            };
          };
        }
      );
      # ==========================================
      # Hosts
      # ==========================================
      nixosConfigurations = {
        macbook = mkHost { hostname = "macbook"; system = "x86_64-linux"; };
        dell = mkHost { hostname = "dell"; system = "x86_64-linux"; };
      };
    } // (import ./devshells.nix { inherit nixpkgs-stable fenix flake-utils; });
}
