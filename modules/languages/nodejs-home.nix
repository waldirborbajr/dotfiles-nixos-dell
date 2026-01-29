# modules/languages/nodejs-home.nix
# Node.js home-manager configuration (aliases, environment variables)
{ config, lib, ... }:

{
  config = lib.mkIf config.languages.nodejs.enable {
    # Environment variables
    home.sessionVariables = {
      NPM_CONFIG_UPDATE_NOTIFIER = "false";
      NPM_CONFIG_FUND = "false";
      NPM_CONFIG_AUDIT = "false";
    };

    # Shell aliases for Node.js workflows
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      ni = "pnpm install";
      nr = "pnpm run";
      nx = "pnpm dlx nx";
    };
  };
}
