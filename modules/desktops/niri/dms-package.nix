# modules/desktops/niri/dms-package.nix
# Build DankMaterialShell from source if not available in nixpkgs
{ config, pkgs, lib, hostname, fetchFromGitHub, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";

  # DankMaterialShell package
  # Note: This is a placeholder. Update with actual build instructions
  # when the project structure is known.
  dank-material-shell = pkgs.stdenv.mkDerivation rec {
    pname = "dank-material-shell";
    version = "0.1.0";

    # TODO: Update with actual repository URL
    src = fetchFromGitHub {
      owner = "dank-os";
      repo = "dank-material-shell";
      rev = "v${version}";
      sha256 = lib.fakeSha256; # Replace with actual hash
    };

    nativeBuildInputs = with pkgs; [
      pkg-config
      meson
      ninja
      cmake
      git
    ];

    buildInputs = with pkgs; [
      glib
      gtk4
      libadwaita
      json-glib
      cairo
      pango
      gdk-pixbuf
      wayland
      wayland-protocols
      wlroots_0_18
      pixman
      libxkbcommon
      libinput
      mesa
      vulkan-loader
      vulkan-headers
    ];

    mesonFlags = [
      "-Dwayland=true"
      "-Dniri=true"
    ];

    postInstall = ''
            # Install additional resources
            mkdir -p $out/share/dank-material-shell
            cp -r themes $out/share/dank-material-shell/ || true
            cp -r icons $out/share/dank-material-shell/ || true
      
            # Create wrapper script
            mkdir -p $out/bin
            cat > $out/bin/dank-material-shell << EOF
      #!/usr/bin/env bash
      export DMS_DATA_DIR=$out/share/dank-material-shell
      export DMS_CONFIG_DIR=\$HOME/.config/DankMaterialShell
      exec $out/libexec/dank-material-shell "\$@"
      EOF
            chmod +x $out/bin/dank-material-shell
    '';

    meta = with lib; {
      description = "Modern Material Design shell for Wayland compositors";
      homepage = "https://github.com/dank-os/dank-material-shell";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      maintainers = [ ];
    };
  };

in
{
  # Export the package for use in other modules
  options = {
    programs.dank-material-shell = {
      enable = lib.mkEnableOption "DankMaterialShell";
      package = lib.mkOption {
        type = lib.types.package;
        default = dank-material-shell;
        description = "The DankMaterialShell package to use";
      };
    };
  };

  config = lib.mkIf (isMacbook && config.programs.dank-material-shell.enable) {
    home.packages = [ config.programs.dank-material-shell.package ];
  };
}
