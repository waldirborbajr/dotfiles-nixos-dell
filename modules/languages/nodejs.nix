# modules/languages/nodejs.nix
# Consolidado: common + enable
{ pkgs, lib, ... }:

let
  enableNode = false; # true | false
in
{
  environment.systemPackages = lib.optionals enableNode (with pkgs; [
    nodejs_20
    nodePackages.pnpm
  ]);

  environment.variables = {
    NPM_CONFIG_UPDATE_NOTIFIER = "false";
    NPM_CONFIG_FUND = "false";
    NPM_CONFIG_AUDIT = "false";
  };

  environment.shellAliases = lib.mkIf enableNode {
    ni = "pnpm install";
    nr = "pnpm run";
    nx = "pnpm dlx nx";
  };
}
