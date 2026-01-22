# modules/nixpkgs.nix
{ inputs, system, ... }:

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
