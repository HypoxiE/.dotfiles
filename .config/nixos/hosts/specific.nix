{ config, lib, pkgs, host, ... }:

lib.foldl' lib._moduleConcat {} [

	(lib.mkIf (host == "hynix") {
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
	})

	(lib.mkIf (host == "hypoxlaptop") {
		services.logind.settings.Login = {
			HandleLidSwitch = "ignore";
			HandleLidSwitchExternalPower = "ignore";
			HandleLidSwitchDocked = "ignore";
		};
		services.acpid = {
			handlers.lid = {
				event = "button/lid.*";
				action = "${pkgs.python3}/bin/python3 /home/hypoxie/scripts/lid_toggle/main.py";
			};
		};

		systemd.services.lid_toggle_startup = {
			description = "Run lid_toggle script once at startup";
			after = [ "network.target" ];
			wantedBy = [ "systemd-modules-load.service" "multi-user.target" ];

			serviceConfig = {
				ExecStart = "${pkgs.bash}/bin/bash -c 'until [ -e /sys/class/backlight/amdgpu_bl1/max_brightness ]; do sleep 0.1; done; ${pkgs.python3}/bin/python3 /home/hypoxie/scripts/lid_toggle/main.py'";
				Type = "oneshot";
				RemainAfterExit = true;
			};
		};
		systemd.services.lid_toggle_shutdown = {
			description = "Run custom script on shutdown/reboot";
			wantedBy = [ "multi-user.target" ];

			serviceConfig = {
				Type = "oneshot";
				ExecStart = "${pkgs.coreutils}/bin/true";
				ExecStop = "${pkgs.python3}/bin/python3 /home/hypoxie/scripts/lid_toggle/main.py --state open";
				RemainAfterExit = true;
				DefaultDependencies = false;
				Before = [ "shutdown.target" ];
			};
		};
	})
];