{
  description = "BORBA JR W NixOS + Home Manager";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS profiles to optimize settings for different hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Global catppuccin theme
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { 
    self,
    catppuccin,
    home-manager,
    nixpkgs,
    nixpkgs-stable,
    ... } @inputs: 
  let
    system = "x86_64-linux";

    # Carrega as configs de usuários (de common/users.nix ou defina aqui)
    userConfigs = import ./common/users.nix;   # ou inline:
    # userConfigs = {
    #   borba = { fullName = "..."; email = "..."; gitKey = "..."; };
    #   devops = { ... };
    # };

    # Função auxiliar para criar configurações NixOS
    mkNixos = hostname: extraModules: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { 
        inherit inputs;
        pkgs-stable = import nixpkgs-stable { inherit system; };
        userConfigs = userConfigs;  # ← opcional: passa para NixOS também se precisar
      };
      modules = [
        ./common/configuration.nix
        ./common/packages.nix
        ./common/fonts.nix
        ./common/programs.nix
        (./hosts + "/${hostname}")
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            # Para cada usuário, passe extraSpecialArgs específico dele
            extraSpecialArgs = { inherit inputs; userConfig = userConfigs.${username}; };
            
            users = {
              borba = import ./home/borba/default.nix;
              devops = import ./home/devops/default.nix;
            };

            extraSpecialArgs = { inherit inputs; };
          };
        }
      ] ++ extraModules;
    };

  in {
    nixosConfigurations = {
      # Adicione quantos computadores quiser
      dell   = mkNixos "dell"   [];
      macbook  = mkNixos "macbook"  [];
      # servidor = mkNixos "servidor" [];
      # thinkpad = mkNixos "thinkpad" [];
    };

    # Opcional: permite rodar `nix flake check`, `nix fmt`, etc.
  };
}