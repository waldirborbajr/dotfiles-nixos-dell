# modules/languages/python-home.nix
# Python home-manager configuration (aliases, environment variables)
{ config, lib, ... }:

{
  config = lib.mkIf config.languages.python.enable {
    # Environment variables
    home.sessionVariables = {
      PIP_DISABLE_PIP_VERSION_CHECK = "1";
      PYTHONDONTWRITEBYTECODE = "1";
      POETRY_VIRTUALENVS_IN_PROJECT = "true";
    };

    # Shell aliases for Python workflows
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      # UV aliases (modern Python)
      venv = "uv venv";
      py = "uv run python";
      pip = "uv pip";
      
      # Poetry alternative (if using poetry instead)
      # py = "poetry run python";
    };
  };
}
