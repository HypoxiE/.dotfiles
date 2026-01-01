#{
#  description = "NixOS + Home Manager flake";

#  inputs = {
#    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#    home-manager.url = "github:nix-community/home-manager";
#    nur.url = "github:nix-community/NUR";
#    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
#  };

#  outputs = { self, nixpkgs, home-manager, nur, spicetify-nix, ... }:

#  let
#    system = "x86_64-linux";
#    pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay ]; };
#  in
#  {
#    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
#      inherit system;

#      modules = [
#        ./hosts/hardware-configuration.nix
#        ./hosts/laptop.nix
#        home-manager.nixosModules.home-manager

#        {
#          home-manager.users.hypoxie = import ./home/hypoxie.nix;
#        }
#      ];
#    };
#  };
#}


{
  description = "NixOS + Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = { self, nixpkgs, home-manager, nur, spicetify-nix, ... }:

  let
    system = "x86_64-linux";
    username = "hypoxie";
    pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay ]; };
  in
  {
    # NixOS конфигурация
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/hardware-configuration.nix
        ./hosts/laptop.nix
        home-manager.nixosModules.home-manager
        { home-manager.users.hypoxie = import ./home/hypoxie.nix; }
      ];
    };

    # Отдельная конфигурация Home Manager
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system; };
      modules = [ ./home/hypoxie.nix ];

      #extraSpecialArgs = {
      #  spicetify-nix = spicetify-nix;
      #};
    };
  };
}
