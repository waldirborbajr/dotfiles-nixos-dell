# flake.nix
# ---
{
  description = "BORBA JR W - Multi-host NixOS Flake";
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (seguindo nixpkgs-stable para compatibilidade)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Theme: Catppuccin (centralizado)
    catppuccin.url = "github:catppuccin/nix";

    # DevShells: Rust toolchains via fenix
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # DevShells: Helper para múltiplos sistemas
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, catppuccin, fenix, flake-utils, ... }:
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
          inherit inputs devopsEnabled qemuEnabled hostname; # ← adicionado hostname aqui
        };
        modules = [
          # Aplique o system via módulo (recomendado em 25.11+)
          ({ config, pkgs, lib, ... }: {
            nixpkgs.hostPlatform = system; # <-- Isso define o hostPlatform corretamente
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [ unstableOverlay ];
          })
          ./core.nix
          (./hosts + "/${hostname}.nix")

          # Theme: Catppuccin NixOS module
          catppuccin.nixosModules.catppuccin

          # Novo: importa o home-manager como módulo NixOS
          home-manager.nixosModules.home-manager

          # Configuração básica do home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs devopsEnabled qemuEnabled hostname; # ← adicionado hostname aqui também
            };

            # Correção: usuário correto é "borba"
            home-manager.users.borba = { config, pkgs, lib, hostname, ... }: {  # ← recebe hostname
              imports = [
                ./home.nix
                # Theme: Catppuccin Home Manager module
                catppuccin.homeModules.catppuccin
                # Outros módulos podem usar hostname se necessário
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
      (import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      }).nixpkgs-fmt
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
