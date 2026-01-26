# modules/languages/python.nix
# Consolidado: common + uv + poetry
{ pkgs, lib, ... }:

let
  pythonEnv = "uv"; # uv | poetry | none
in
{
  # ========================================
  # Python base (sempre ativo)
  # ========================================
  environment.systemPackages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
  ] ++ lib.optionals (pythonEnv == "uv") [
    uv
  ] ++ lib.optionals (pythonEnv == "poetry") [
    poetry
  ];

  environment.variables = {
    PIP_DISABLE_PIP_VERSION_CHECK = "1";
    PYTHONDONTWRITEBYTECODE = "1";
  } // lib.optionalAttrs (pythonEnv == "poetry") {
    POETRY_VIRTUALENVS_IN_PROJECT = "true";
  };

  environment.shellAliases = lib.mkMerge [
    (lib.mkIf (pythonEnv == "uv") {
      venv = "uv venv";
      py   = "uv run python";
      pip  = "uv pip";
    })
    (lib.mkIf (pythonEnv == "poetry") {
      py = "poetry run python";
    })
  ];
}
