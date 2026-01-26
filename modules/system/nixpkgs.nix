# modules/nixpkgs.nix
{ ... }:

{
  nixpkgs = {
    config.allowUnfree = true;
  };
}
