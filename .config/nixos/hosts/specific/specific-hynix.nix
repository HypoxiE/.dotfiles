{ config, lib, pkgs, host, ... }:

lib.mkIf (host == "hynix") {

	swapDevices = [
		{
			device = "/swap/swapfile";
			size = 32022;
			priority = -300;
		}
	];

	boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
	hardware.graphics.enable = true;
	services.xserver.videoDrivers = [ "nvidia" ];
	hardware.nvidia = {
		modesetting.enable = true;
		powerManagement.finegrained = false;
		open = false;
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
		prime.nvidiaBusId = "PCI:01:00.0";
	};
}
