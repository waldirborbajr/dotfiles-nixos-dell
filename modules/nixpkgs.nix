{ lib, pkgs, ... }:

let
  unstablePkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000"; # placeholder
  }) {
    config = { allowUnfree = true; };
  };
in
{
  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (final: prev: {
        unstable = unstablePkgs;
      })
    ];
  };
}
