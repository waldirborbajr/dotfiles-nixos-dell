# modules/apps/gh.nix
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [ gh ];

  # Config declarativa para gh via systemd user service (cria ~/.config/gh/config.yml)
  systemd.user.services."gh-config-setup" = {
    description = "Setup declarative gh config.yml";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      mkdir -p "$HOME/.config/gh"

      cat > "$HOME/.config/gh/config.yml" << 'EOF'
      version: 1
      git_protocol: https
      editor:
      prompt: enabled
      prefer_editor_prompt: disabled
      pager:
      aliases:
        co: pr checkout
        pv: pr view --web
        pi: pr create --fill --web
        il: issue list --limit 20
        ic: issue create --web
      hosts:
        github.com:
          git_protocol: ssh
          users:
            waldirborbajr: {}
            omnicwbdev: {}
          user: omnicwbdev
        gitlab.com:
          git_protocol: ssh
          users:
            waldirborbajr: {}
            omnicwbdev: {}
          user: waldirborbajr
      EOF

      chmod 600 "$HOME/.config/gh/config.yml"
    '';
  };
}
