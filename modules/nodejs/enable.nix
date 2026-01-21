{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  ############################################
  # NodeJS (enabled)
  ############################################

  environment.systemPackages = with pkgs; [
    nodejs_20   # LTS
    nodePackages.pnpm
  ];

  environment.shellAliases = {
    ni = "pnpm install";
    nr = "pnpm run";
    nx = "pnpm dlx nx";
  };
}
