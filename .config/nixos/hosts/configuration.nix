# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, host ? "default", ... }:

let
	go-login = pkgs.buildGoModule {
		pname = "go-login";
		version = "0.0.0";

		src = pkgs.fetchgit {
			url = "https://github.com/HypoxiE/go-login-system.git";
			rev = "de035b15e75a7c52dd915375f64f7c095184f432";
			hash = "sha256-ZbockZFesNu+l6QY3SV+50xB6WVnQdd7iTDEDf7xx8k=";
		};

		vendorHash = "sha256-ith7A1fSk42DWQQiFItynpO2fKAfQm+tesAPILszwDs=";

		buildInputs = with pkgs; [
			pam
		];

		nativeBuildInputs = with pkgs; [
			pkg-config
			makeWrapper
		];

		env = {
			CGO_ENABLED = 1;
		};

		postFixup = ''
			wrapProgram $out/bin/go-login \
				--prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.pam ]}
		'';

		meta = with pkgs.lib; {
			description = "Console login program for system";
			license = licenses.mit;
			platforms = platforms.linux;
		};
	};

	scriptsDir = ../../../scripts;
	scripts = builtins.attrNames (builtins.readDir scriptsDir);
in
{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	environment.etc = builtins.listToAttrs (map (name: {
		name = name;
		value = {
			source = "${scriptsDir}/${name}";
		};
	}) scripts);

	#Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = false;
	#boot.loader.efi.canTouchEfiVariables = true;
	#boot.initrd.systemd.enable = true;
	#boot.initrd.enable = true;
	#boot.loader.systemd-boot.useUnifiedKernelImages = true;
	boot.extraModprobeConfig = ''
		# Intel 7265 фиксы
		#options iwlwifi power_save=0
		#options iwlwifi uapsd_disable=1

		# если будут зависания — раскомментируй:
		# options iwlwifi disable_11n=1
	'';
	boot.loader.grub = {
		enable = true;
		configurationLimit = 5;
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

		theme = let
			baseTheme = pkgs.fetchFromGitHub {
				owner = "NyarchLinux";
				repo = "Nyarch-Grub-Theme";
				rev = "8cb88c7ad161ebc8e72fe6c7b1f70cf0f511d639";
				sha256 = "sha256-i77XGqIkECO2+Vw6ntZ1DVKPt42lPYjJU/qysL7fjDs=";
			};
		in pkgs.runCommand "custom-grub-theme" {} ''
			mkdir -p $out
			mkdir -p $out/images

			cp -r ${baseTheme}/Nyarch-theme/. $out/
			
			install -Dm644 ${../grub_textures/background.png} $out/background.png
			install -Dm644 ${../grub_textures/progress_highlight_c.png} $out/images/progress_highlight_c.png
		'';
	};
	boot.tmp.useTmpfs = true;
	boot.tmp.zramSettings.zram-size = "min(ram / 2, 512)";

	networking.hostName = host;

	imports = [ ./specific/specific-hynix.nix ./specific/specific-laptop.nix ];

	# Configure network connections interactively with nmcli or nmtui.
	#networking = {
	#	wireless.iwd.enable = true;
	#	networkmanager = {
	#		enable = false;
	#		wifi.backend = "iwd";
	#	};
	#};
	networking = {
		wireless.iwd = {
			enable = true;

			settings = {
				General = {
					EnableNetworkConfiguration = true;
				};

				Station = {
				PowerSave = false;
				};
			};
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
	#systemd.services."getty@tty2".enable = true;
	#systemd.services."getty@tty2".serviceConfig = {
	#	ExecStart = pkgs.lib.mkForce [
	#		""
	#		"${pkgs.util-linux}/bin/agetty --skip-login --noissue --noclear --login-program ${go-login}/bin/go-login %I $TERM"
	#	];
	#	Type = "idle";
	#	NoNewPrivileges = "no";
	#};
	#services.getty.extraArgs = ["--skip-login" "--noissue" "--noclear"];
	#services.getty.loginProgram = "${go-login}/bin/go-login";
	#systemd.units."getty@tty2.service".serviceConfig = {
	#	NoNewPrivileges = "no";
	#};
	#systemd.services."getty@".serviceConfig = {
	#	ExecStart = [
	#		""
	#		"${pkgs.util-linux}/bin/agetty --skip-login --noissue --noclear --login-program ${pkgs.util-linux}/bin/login -- ${go-login}/bin/go-login %I $TERM"
	#	];
	#	Type = "idle";
	#	NoNewPrivileges = "no";
	#};

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
		systemd.services.ydotoold = {
		description = "ydotool daemon";
		wantedBy = [ "multi-user.target" ];
		after = [ "network.target" ];

		serviceConfig = {
			ExecStart = "${pkgs.ydotool}/bin/ydotoold";
			Restart = "always";
			RestartSec = 1;
		};
	};
	
	services.acpid = {
		enable = true;
	};


	programs.hyprland.enable = true;
	programs.steam.enable = true;
	programs.xwayland.enable = true;
	#programs.zoxide.enable = true;
	#programs.home-manager.enable = true;

	hardware.bluetooth.enable = true;
	hardware.bluetooth.powerOnBoot = true;

	#programs.nix-ld.enable = true;

	# List packages installed in system profile.
	# You can use https://search.nixos.org/ to find more packages (and options).
	environment.systemPackages = with pkgs; [
		go-login

		#libs
		pkg-config

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
		ydotool # автокликер

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
		scol = "${config.environment.etc."set_themes".source}/main.py";
		wset = "${config.environment.etc."set_wallpapers".source}/main.py";
		nohup = "nohup 2>&1 > ~/logs/nohup.out";
		py = "python3";
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

