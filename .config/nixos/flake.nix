
{
	description = "NixOS + Home Manager flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
		
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nur.url = "github:nix-community/NUR";
		stylix.url = "github:danth/stylix";

		spicetify-nix.url = "github:Gerg-L/spicetify-nix";

		disko = {
			url = "github:nix-community/disko";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, nur, stylix, spicetify-nix, disko, ... }:

	let
		system = "x86_64-linux";
		pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay  spicetify-nix.overlays.default ]; };
	in
	{
		nixosConfigurations = {
			laptop = nixpkgs.lib.nixosSystem {
				modules = [
					./hosts/hardware-configuration.nix
					./hosts/configuration.nix
					./disko.nix
					disko.nixosModules.disko
					stylix.nixosModules.stylix
					home-manager.nixosModules.home-manager
					{ _module.args.host = "hypoxlaptop"; }
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;

						home-manager.sharedModules = [
							spicetify-nix.homeManagerModules.default
							stylix.homeModules.stylix
						];

						home-manager.users.hypoxie = { config, pkgs, ... }: import ./home/hypoxie.nix {
							inherit config pkgs;
							spicetify-nix = spicetify-nix;
							stylix = stylix;
						};
					}
				];
			};
			pc = nixpkgs.lib.nixosSystem {
				modules = [
					./hosts/hardware-configuration.nix
					./hosts/configuration.nix
					./disko.nix
					disko.nixosModules.disko
					stylix.nixosModules.stylix
					home-manager.nixosModules.home-manager
					{ _module.args.host = "hynix"; }
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;

						home-manager.sharedModules = [
							spicetify-nix.homeManagerModules.default
							stylix.homeModules.stylix
						];

						home-manager.users.hypoxie = { config, pkgs, ... }: import ./home/hypoxie.nix {
							inherit config pkgs;
							spicetify-nix = spicetify-nix;
							stylix = stylix;
						};
					}
				];
			};
		};
	};
}
