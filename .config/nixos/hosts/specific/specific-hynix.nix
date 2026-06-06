{ config, lib, pkgs, host, ... }:

lib.mkIf (host == "hynix") {

	swapDevices = [
		{
			device = "/swap/swapfile";
			size = 32022;
			priority = -300;
		}
	];
    # services.xserver.videoDrivers = [ ];
    # boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
    # boot.kernelParams = [
    #     "iommu=pt"
    #     "pcie_acs_override=downstream"
    #     "vfio-pci.ids=10de:1f0a,10de:10f9"
    # ];
    # boot.blacklistedKernelModules = [
    #     "nouveau"
    #     "nvidia"
    #     "nvidia_drm"
    #     "nvidia_modset"
    # ];

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
