{ config, lib, pkgs, host, ... }:

lib.mkIf (host == "hyflash") {

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

	fileSystems."/" = lib.mkForce {
		device = "tmpfs";
		fsType = "tmpfs";
		options = [ "mode=755" ];
	};

	fileSystems."/home/hypoxie" = lib.mkForce {
		device = "none";
		fsType = "tmpfs";
		options = [ "defaults" "size=4G" "mode=777" ];
		neededForBoot = true;
	};

	boot.initrd.luks.devices."cryptpersist" = {
		device = "/dev/pool/persist";
		preLVM = false;
		allowDiscards = true;
	};

	environment.persistence."/persistent" = {
		hideMounts = true;
		directories = [
			"/etc/NetworkManager/system-connections"
			"/var/lib/bluetooth"
			"/root"
			"/var/log"
			"/var/lib/systemd"
		];
		files = [
			"/etc/machine-id"
			#"/etc/ssh/ssh_host_ed25519_key"
			#"/etc/ssh/ssh_host_ed25519_key.pub"
		];
	};

	boot.kernelParams = [ "page_poison=1" ];

	swapDevices = lib.mkForce [ ];

	environment.interactiveShellInit = ''
		unset HISTFILE
	'';
}