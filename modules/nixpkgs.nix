let
  unstablePkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    sha256 = "0hx09ar14njl4vgarsy79vlykwswg7rbxak7c7qm1n8r0szy6r0b";
  }) {
    system = "x86_64-linux";      # <<<<< ESSENCIAL
    config = { allowUnfree = true; };
  };
in
{
  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      })
    ];
  };
}

# # modules/nixpkgs.nix
# { lib, pkgs, ... }:

# let
#   unstablePkgs = import (builtins.fetchTarball {
#     url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
#   }) {
#     config = { allowUnfree = true; };
#   };
# in
# {
#   nixpkgs = {
#     config.allowUnfree = true;

#     overlays = [
#       (final: prev: {
#         unstable = unstablePkgs;
#       })
#     ];
#   };
# }
