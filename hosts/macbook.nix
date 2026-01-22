{ ... }:

{
  imports = [
    ##########################################
    # Hardware
    ##########################################
    ../hardware/macbook.nix
    ../modules/hardware/macbook.nix
    ../modules/performance/macbook.nix

  ];
}
