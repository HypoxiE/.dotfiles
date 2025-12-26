{
  description = "NixOS + Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, nur, ... }:

  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay ]; };
  in
  {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./hosts/hardware-configuration.nix   # hardware-configuration.nix первым!
        ./hosts/laptop.nix                    # остальные настройки
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.hypoxie = import ./home/hypoxie.nix;
        }
      ];
    };
  };
}
