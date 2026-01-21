{ lib, ... }:

let
  enableNode = false; # true | false
in
{
  imports =
    lib.optionals enableNode [
      ./enable.nix
    ];
}
