
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

		neu-nix.url = "github:ricardomaps/neu-nix";

		disko = {
			url = "github:nix-community/disko";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, nur, stylix, spicetify-nix, neu-nix, disko, ... }:

	let
		system = "x86_64-linux";
		pkgs = import nixpkgs {
			inherit system;
			overlays = [ nur.overlays.default neu-nix.overlays.default ];
			config = {
				allowUnfree = true;
			};
		};
		
		mkHost = { hostname }:
			nixpkgs.lib.nixosSystem {
				inherit system pkgs;

				modules = [

					./hosts/hardware-configuration.nix
					./hosts/configuration.nix
					./disko.nix

					disko.nixosModules.disko
					stylix.nixosModules.stylix
					home-manager.nixosModules.home-manager

					{
						_module.args.host = hostname;

						home-manager.useUserPackages = true;

						home-manager.sharedModules = [
						spicetify-nix.homeManagerModules.default
						stylix.homeModules.stylix
						];

						home-manager.extraSpecialArgs = {
						inherit pkgs hostname;
						host = hostname;
						};

						home-manager.users.hypoxie =
						{ config, pkgs, host, ... }:
						import ./home/hypoxie.nix {
							inherit config pkgs host spicetify-nix stylix;
						};
					}
				];
			};
	in
	{
		nixosConfigurations = {
			laptop = mkHost {
				hostname = "hypoxlaptop";
			};
			pc = mkHost {
				hostname = "hynix";
			};
		};
	};
}
