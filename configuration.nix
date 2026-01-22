{ ... }:

{
  imports = [
    ./hosts/macbook.nix
    # ./hosts/dell.nix
  ];

  system.stateVersion = "25.11";
}
