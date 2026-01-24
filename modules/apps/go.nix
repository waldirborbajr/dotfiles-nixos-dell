{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    go_1_23     # ou a versão que você mais usa
    gopls
    delve       # debugger opcional
  ];

  # Opcional: variáveis para Go
  home.sessionVariables = {
    GOPATH = "$HOME/go";
    PATH = "$GOPATH/bin:$PATH";
  };
}
