# modules/languages/lua.nix
# Lua development environment
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.languages.lua.enable {
    # ========================================
    # Lua packages (global)
    # ========================================
    home.packages = with pkgs; [
      lua5_4 # Lua interpreter
      luajit # JIT compiler (faster)
      luarocks # Package manager
      lua-language-server # LSP
      stylua # Formatter
      selene # Linter
    ];

    # ========================================
    # Shell aliases
    # ========================================
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      lua = "lua5.4";
      luai = "lua5.4 -i"; # Interactive mode
      luac = "luac5.4"; # Compiler
      lrocks = "luarocks";
      lfmt = "stylua";
    };

    # ========================================
    # Environment variables
    # ========================================
    home.sessionVariables = {
      LUA_PATH = "${config.home.homeDirectory}/.luarocks/share/lua/5.4/?.lua;${config.home.homeDirectory}/.luarocks/share/lua/5.4/?/init.lua;;";
      LUA_CPATH = "${config.home.homeDirectory}/.luarocks/lib/lua/5.4/?.so;;";
    };
  };
}
