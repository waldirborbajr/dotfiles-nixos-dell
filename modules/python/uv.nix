{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  ############################################
  # Python env manager: uv (preferred)
  ############################################

  environment.systemPackages = with pkgs; [
    uv
  ];

  environment.shellAliases = {
    venv = "uv venv";
    py   = "uv run python";
    pip  = "uv pip";
  };
}
