# common/users.nix
{
  borba = {
    fullName = "Waldir Borba";
    email    = "borba@example.com";
    gitKey   = "ABCDEF1234567890";  # ou use sops/agenix para secrets reais
  };

  devops = {
    fullName = "DevOps User";
    email    = "devops@empresa.com";
    gitKey   = "9876543210FEDCBA";
  };
}