# modules/apps/fun-tools.nix
# CLI fun and aesthetic tools
{ config, pkgs, lib, ... }:

{
  config = {
    home.packages = lib.lists.optionals config.apps.cbonsai.enable [ pkgs.cbonsai ]
      ++ lib.lists.optionals config.apps.cmatrix.enable [ pkgs.cmatrix ]
      ++ lib.lists.optionals config.apps.pipes.enable [ pkgs.pipes ]
      ++ lib.lists.optionals config.apps.tty-clock.enable [ pkgs.tty-clock ];
  };
}
