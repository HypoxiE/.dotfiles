# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, host ? "default", ... }:

let
	lidToggleScript = pkgs.writeScriptBin "lid_toggle" (builtins.readFile ../../../scripts/lid_toggle/main.py);
in
{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	#Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = false;
	#boot.loader.efi.canTouchEfiVariables = true;
	#boot.initrd.systemd.enable = true;
	#boot.initrd.enable = true;
	#boot.loader.systemd-boot.useUnifiedKernelImages = true;
	boot.loader.grub.configurationLimit = 5;
	boot.loader.grub = {
		enable = true;
		#devices = [ "/dev/disk/by-id/nvme-XPG_GAMMIX_S11_Pro_2P082LQ8B2UF" ];
		devices = [ "nodev" ];
		efiSupport = true;
		efiInstallAsRemovable = true;
		extraEntries = ''
			menuentry "Shutdown" {
				echo "Shutting down..."
				halt --no-apm
				poweroff
			}
		'';
	};
	boot.tmp.useTmpfs = true;
	boot.tmp.zramSettings.zram-size = "min(ram / 2, 512)";

	networking.hostName = host;

	boot.extraModulePackages =
	lib.mkIf (host == "hynix")
	[ config.boot.kernelPackages.nvidia_x11 ];

	hardware.graphics.enable =
		lib.mkIf (host == "hynix") true;

	services.xserver.videoDrivers =
		lib.mkIf (host == "hynix") [ "nvidia" ];

	hardware.nvidia =
		lib.mkIf (host == "hynix") {
		modesetting.enable = true;
		powerManagement.finegrained = false;
		open = false;
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
		prime.nvidiaBusId = "PCI:01:00.0";
		};

	# Configure network connections interactively with nmcli or nmtui.
	networking = {
		wireless.iwd.enable = true;
		networkmanager = {
			enable = false;
			wifi.backend = "iwd";
		};
	};

	# Set your time zone.
	time.timeZone = "Europe/Moscow";

	# Configure network proxy if necessary
	networking.proxy = {
		default = "socks5://127.0.0.1:10808";
		httpProxy = "http://127.0.0.1:10808";
		httpsProxy = "http://127.0.0.1:10808";
		noProxy = "127.0.0.1,localhost,internal.domain";
	};

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	i18n.supportedLocales = [ "ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
	#console = {
	#  font = "cyr-sun16";
	#  keyMap = "ru";
	#  useXkbConfig = false; # use xkb.options in tty.
	#};

	# Enable the X11 windowing system.
	#services.xserver.enable = true;

	# Configure keymap in X11
	#services.xserver.xkb.layout = "us,ru";
	# services.xserver.xkb.options = "eurosign:e,caps:escape";

	# Enable CUPS to print documents.
	# services.printing.enable = true;

	# Enable sound.
	# services.pulseaudio.enable = true;
	# OR
	services.pipewire = {
		enable = true;
		pulse.enable = true;
	};
	
	services.xray = {
		enable = true;
		settingsFile = "/etc/xray/config.json";
	};
	services.printing = { 
		enable = true;
		drivers = [ pkgs.pantum-driver ];
	};

	# Enable touchpad support (enabled default in most desktopManager).
	# services.libinput.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.hypoxie = {
		isNormalUser = true;
		home = "/home/hypoxie";
		extraGroups = [ "wheel" "video" "input" "networkmanager" "dialout" "uucp" ];
		password = "12345678";
	};

	services.udev.extraRules = ''
		SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0860", MODE="0666"
		SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", MODE="0666"
		SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d038", MODE="0666"
	'';
	services.udisks2.enable = true;

	services.logind.settings.Login = {
		HandleLidSwitch = "ignore";
		HandleLidSwitchExternalPower = "ignore";
		HandleLidSwitchDocked = "ignore";
	};
	services.acpid = {
		enable = true;
		handlers.lid = {
			event = "button/lid.*";
			action = "#!/usr/bin/env python3 \n /home/hypoxie/scripts/lid_toggle/main.py";
		};
	};
	systemd.services.lid_toggle = {
		description = "Run lid_toggle script once at startup";
		after = [ "network.target" ];
		wantedBy = [ "multi-user.target" ];

		serviceConfig = {
			ExecStart = "#!/usr/bin/env python3 \n ${lidToggleScript}";
			Type = "oneshot";
			RemainAfterExit = true;
		};
	};


	programs.hyprland.enable = true;
	programs.steam.enable = true;
	programs.xwayland.enable = true;
	#programs.zoxide.enable = true;
	#programs.home-manager.enable = true;

	hardware.bluetooth.enable = true;
	hardware.bluetooth.powerOnBoot = true;

	# List packages installed in system profile.
	# You can use https://search.nixos.org/ to find more packages (and options).
	environment.systemPackages = with pkgs; [
		#libs
		pkg-config

		pam
		cups pantum-driver # принтеры
		socat
		gnumake
		wl-clipboard
		wl-clip-persist
		adwaita-icon-theme
		pulseaudio # регулировка звука
		playerctl # управление музыкой
		brightnessctl ddcutil # яркость
		acpid # выключение экрана

		vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		tree
		htop
		iwd # wifi
		bluez # bluetooth
		wget # для web запросов
		gtk3 # Необходимо для запуска gui приложений
		wev # Для получения кейкодов клавиш
		neofetch
		git
		zoxide fzf # для поиска
		xray
		# for screenshots
		grim
		slurp
		nftables
		remmina # Для подключения к виртуалке винды

		hyprland
		hyprlock hyprpicker eww swww
		wayland wayland-protocols
		kitty
		wofi
		swaynotificationcenter

		go
		python3
		texlive.combined.scheme-full
		#libgcc
		gcc
		cmake       # CMake (опционально)
		gdb         # отладчик
		ninja       # если нужен fast build
		clang       # альтернативный компилятор

		stow
		clipse
		udiskie
	];
	fonts.packages = with pkgs; [
		material-symbols
		liberation_ttf
	];

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#   enable = true;
	#   enableSSHSupport = true;
	# };

	services.syncthing = {
		enable = true;
		user = "hypoxie";
		dataDir = "/home/hypoxie";
		configDir = "/home/hypoxie/.config/syncthing";
	};

	environment.sessionVariables = {
		PATH = "$HOME/.local/bin:$PATH";

		XCURSOR_THEME = "Adwaita";
		XCURSOR_SIZE = "24";
	};

	programs.bash = {
		#enable = true;
		shellAliases = {
		scol = "python3 /home/hypoxie/scripts/set_themes/main.py";
		wset = "/home/hypoxie/scripts/set_wallpapers/main.py";
		nohup = "nohup 2>&1 > ~/logs/nohup.out";
		py = "python3";

		keybordsettings="nix shell nixpkgs#chromium -c chromium --user-data-dir=/tmp/chromium-via";
		};

		interactiveShellInit = ''
		eval "$(${pkgs.zoxide}/bin/zoxide init bash)"
		
		function rebuild {
			if [ $# -gt 0 ]; then
				commit_msg="$*"
				git add . && git commit -m "$commit_msg"
			fi
			
			if [ -d /sys/class/power_supply/BAT* ]; then
				echo "detected laptop";
				sudo nixos-rebuild switch --flake ~/.dotfiles/.config/nixos#laptop
			else
				echo "detected pc";
				sudo nixos-rebuild switch --flake ~/.dotfiles/.config/nixos#pc
			fi
		}
		
		function files {
			local dir
			if [ -n "$1" ]; then
				dir=$(zoxide query -l "$1" | fzf --height 40% --reverse)
			else
				dir=$(zoxide query -l | fzf --height 40% --reverse)
			fi
			
			if [ -n "$dir" ] && [ -d "$dir" ]; then
				cd "$dir"
			fi
		}
		open() {
			xdg-open "$@" & disown
		}
		'';
	};
	

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	# Open ports in the firewall.
	networking.firewall.allowedTCPPorts = [
		22000 #syncthing
		4242 #lan mouse
	];
	networking.firewall.allowedUDPPorts = [
		22000 21027 #syncthing
		4242 #lan mouse
	];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;
	networking.nftables.enable = true;
	#networking.firewall.interfaces."lo".allowed = true;

	virtualisation.docker.enable = true;
	virtualisation.docker.autoPrune.enable = true;



	# Copy the NixOS configuration file and link it from the resulting system
	# (/run/current-system/configuration.nix). This is useful in case you
	# accidentally delete configuration.nix.
	# system.copySystemConfiguration = true;

	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	#
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	#
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	#
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	#
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	#
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "25.11"; # Did you read the comment?

}

