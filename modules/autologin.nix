# modules/autologin.nix
# ---
{ ... }:

{
  services.displayManager.autoLogin = {
    enable = false;
    user = "borba";
  };

  # Prevent TTY race with graphical session
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
