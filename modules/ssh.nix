## Relation truth

#{ ... }:
#
#{
#  services.openssh = {
#    enable = true;
#    openFirewall = true;
#
#    settings = {
#      PermitRootLogin = "no";
#      PasswordAuthentication = false;
#      KbdInteractiveAuthentication = false;
#    };
#  };
#}


## Aak for user and password

{ ... }:

{
  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
      PermitRootLogin = "no";
    };
  };
}
