{ pkgs, ... }:

{
  ############################################
  # NodeJS base (safe)
  ############################################

  environment.variables = {
    NPM_CONFIG_UPDATE_NOTIFIER = "false";
    NPM_CONFIG_FUND = "false";
    NPM_CONFIG_AUDIT = "false";
  };
}
