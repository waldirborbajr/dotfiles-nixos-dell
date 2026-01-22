# configuration.nix
{ ... }:

{
  imports = [
    ./hosts/macbook.nix
    # ./hosts/dell.nix

    ./core.nix
  ];

  system.stateVersion = "25.11";
}
