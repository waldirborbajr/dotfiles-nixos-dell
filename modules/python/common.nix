{ pkgs, ... }:

{
  ############################################
  # Python base (safe, shared)
  ############################################

  environment.systemPackages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
  ];

  environment.variables = {
    PIP_DISABLE_PIP_VERSION_CHECK = "1";
    PYTHONDONTWRITEBYTECODE = "1";
  };
}
