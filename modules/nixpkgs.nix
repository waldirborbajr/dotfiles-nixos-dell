{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import <nixpkgs-unstable> {
        config.allowUnfree = true;
      };
    })
  ];
}
