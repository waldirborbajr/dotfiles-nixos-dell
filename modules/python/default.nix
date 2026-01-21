{ config, lib, ... }:

let
  pythonEnv = "uv"; # uv | poetry
in
{
  imports =
    lib.optionals (pythonEnv == "uv") [
      ./uv.nix
    ]
    ++ lib.optionals (pythonEnv == "poetry") [
      ./poetry.nix
    ];
}
