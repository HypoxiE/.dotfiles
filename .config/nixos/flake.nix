
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

		disko = {
			url = "github:nix-community/disko";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, nur, spicetify-nix, disko, ... }:

	let
		system = "x86_64-linux";
		username = "hypoxie";
		pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay  spicetify-nix.overlays.default ]; };
	in
	{
		nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
			modules = [
				./hosts/hardware-configuration.nix
				./hosts/laptop.nix
				./disko.nix
				disko.nixosModules.disko
				home-manager.nixosModules.home-manager
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;

					home-manager.sharedModules = [
						spicetify-nix.homeManagerModules.default
					];

					home-manager.users.hypoxie = { config, pkgs, ... }: import ./home/hypoxie.nix {
						inherit config pkgs;
						spicetify-nix = spicetify-nix;
					};
				}
			];
		};
	};
}
