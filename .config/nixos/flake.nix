
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
    pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay  spicetify-nix.overlays.default ]; };
  in
  {
    # NixOS конфигурация
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      #inherit system;
      modules = [
        #({ ... }: {
        #  nixpkgs.overlays = [
        #    nur.overlay
        #    #spicetify-nix.overlays.default
        #  ];
        #})
        ./hosts/hardware-configuration.nix
        ./hosts/laptop.nix
        home-manager.nixosModules.home-manager
        #{ home-manager.users.hypoxie = import ./home/hypoxie.nix; }
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.sharedModules = [
            spicetify-nix.homeManagerModules.default
          ];

          home-manager.users.hypoxie = { config, pkgs, ... }: import ./home/hypoxie.nix {
            inherit config pkgs;
            # Передаем spicetify-nix как аргумент
            spicetify-nix = spicetify-nix;
          };
        }
      ];
    };
  };
}
