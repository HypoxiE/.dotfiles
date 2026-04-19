
{
	description = "NixOS + Home Manager flake";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
		
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nur.url = "github:nix-community/NUR";

		impermanence = {
			url = "github:nix-community/impermanence";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		disko = {
			url = "github:nix-community/disko";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, nur, impermanence, disko, ... }:

	let
		system = "x86_64-linux";
		pkgs = import nixpkgs {
			inherit system;
			overlays = [ nur.overlays.default ];
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
					./flash-disko.nix

					disko.nixosModules.disko
					home-manager.nixosModules.home-manager

					impermanence.nixosModules.impermanence
					{
						_module.args.host = hostname;

						home-manager.useUserPackages = true;

						home-manager.sharedModules = [
							impermanence.homeManagerModules.impermanence
						];

						home-manager.extraSpecialArgs = {
							inherit pkgs hostname;
							host = hostname;
						};

						home-manager.users.hypoxie =
							{ config, pkgs, host, ... }:
							import ./home/hypoxie.nix {
								inherit config pkgs host impermanence;
							};
					}
				];
			};
	in
	{
		nixosConfigurations = {
			flash = mkHost {
				hostname = "hyflash";
			};
		};
	};
}
