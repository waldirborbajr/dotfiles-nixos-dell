{ ... }:

{
  services.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };

  # Prevent TTY race with graphical session
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
