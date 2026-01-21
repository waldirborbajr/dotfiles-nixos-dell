{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  ############################################
  # Python env manager: poetry (alternative)
  ############################################

  environment.systemPackages = with pkgs; [
    poetry
  ];

  environment.variables = {
    POETRY_VIRTUALENVS_IN_PROJECT = "true";
  };

  environment.shellAliases = {
    py = "poetry run python";
  };
}
