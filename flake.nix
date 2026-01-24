# flake.nix
# ---
{
  description = "BORBA JR W - Multi-host NixOS Flake";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, ... }:
  let
    lib = nixpkgs-stable.lib;

    # ==========================================
    # Feature flags (require --impure to read env)
    # ==========================================
    devopsEnabled = builtins.getEnv "DEVOPS" == "1";
    qemuEnabled   = builtins.getEnv "QEMU" == "1";

    # ==========================================
    # Overlay: exposes pkgs.unstable for the SAME system
    # Usage inside modules: pkgs.unstable.<pkg>
    # ==========================================
    unstableOverlay = final: prev: {
      unstable = import nixpkgs-unstable {
        system = final.system;
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
        inherit system;

        # Pass flags + inputs into modules when needed
        specialArgs = {
          inherit inputs devopsEnabled qemuEnabled;
        };

        modules = [
          # Always apply overlays/unfree globally for this host
          ({ ... }: { nixpkgs = nixpkgsConfig; })

          ./core.nix
          (./hosts + "/${hostname}.nix")
        ];
      };

    # Systems we care about (formatter + future machines)
    supportedSystems = [
      "x86_64-linux"   # Intel/AMD PCs, most VMs
      "aarch64-linux"  # Apple Silicon, Raspberry Pi (64-bit), ARM VMs
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
      # --------------------------
      # CURRENT (your machines)
      # --------------------------
      macbook = mkHost { hostname = "macbook"; system = "x86_64-linux"; };
      dell    = mkHost { hostname = "dell";    system = "x86_64-linux"; };

      # =========================================================
      # FUTURE / TEMPLATE HOSTS (commented, ready to enable)
      #
      # Create the matching file under:
      #   ./hosts/<name>.nix
      # and uncomment the entry below.
      # =========================================================

      # --------------------------
      # AMD Desktop / Laptop
      # (still x86_64-linux)
      # --------------------------
      # amd = mkHost { hostname = "amd"; system = "x86_64-linux"; };

      # --------------------------
      # Apple Silicon (M1/M2/M3)
      # (aarch64-linux)
      # Notes:
      # - Typically Asahi Linux based NixOS setups
      # - You’ll want host-specific hardware config in ./hosts/apple-m.nix
      # --------------------------
      # apple-m = mkHost { hostname = "apple-m"; system = "aarch64-linux"; };

      # --------------------------
      # Raspberry Pi (64-bit)
      # (aarch64-linux)
      # Notes:
      # - You’ll likely have bootloader/firmware specifics in host file
      # --------------------------
      # raspberry = mkHost { hostname = "raspberry"; system = "aarch64-linux"; };

      # --------------------------
      # Virtual Machine (x86_64)
      # Notes:
      # - Great for testing changes before applying to real metal
      # --------------------------
      # vm-x86 = mkHost { hostname = "vm-x86"; system = "x86_64-linux"; };

      # --------------------------
      # Virtual Machine (ARM)
      # Notes:
      # - Useful on Apple Silicon hosts or ARM servers
      # --------------------------
      # vm-arm = mkHost { hostname = "vm-arm"; system = "aarch64-linux"; };
    };
  };
}