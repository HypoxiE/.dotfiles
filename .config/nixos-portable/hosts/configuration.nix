# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, host ? "default", ... }:

let
	specificDir = ./specific;
	specificFiles = builtins.attrNames (builtins.readDir specificDir);
	specificNixFiles = builtins.filter (f: builtins.match ".*\\.nix" f != null) specificFiles;
	specificImports = map (f: specificDir + ("/" + f)) specificNixFiles;

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

	networking.hostName = host;

	imports = specificImports;

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

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	i18n.supportedLocales = [ "ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

	# Enable touchpad support (enabled default in most desktopManager).
	# services.libinput.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.hypoxie = {
		isNormalUser = true;
		home = "/home/hypoxie";
		extraGroups = [ "wheel" "video" "input" "networkmanager" "dialout" "uucp" ];
		password = "12345678";
	};

	services.udisks2.enable = true;
	hardware.uinput.enable = true;

	programs.hyprland.enable = true;
	programs.xwayland.enable = true;

	#hardware.bluetooth.enable = true;
	#hardware.bluetooth.powerOnBoot = true;

	#programs.nix-ld.enable = true;

	# List packages installed in system profile.
	# You can use https://search.nixos.org/ to find more packages (and options).
	environment.systemPackages = with pkgs; [
		#libs
		pkg-config
		socat

		vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		tree
		htop
		iwd # wifi
		#bluez # bluetooth
		wget # для web запросов
		gtk3 # Необходимо для запуска gui приложений
		wev # Для получения кейкодов клавиш
		git
		zoxide fzf # для поиска
		nftables

		go
		python3
		gcc

		stow
		udiskie
	];
	fonts.packages = with pkgs; [
		material-symbols
	];

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#   enable = true;
	#   enableSSHSupport = true;
	# };

	#environment.sessionVariables = {
	#	PATH = "$HOME/.local/bin:$PATH";

	#	XCURSOR_THEME = "Adwaita";
	#	XCURSOR_SIZE = "24";
	#};

	programs.bash = {
		#enable = true;
		shellAliases = {
			scol = "${config.environment.etc."set_themes".source}/main.py";
			wset = "${config.environment.etc."set_wallpapers".source}/main.py";
			nohup = "nohup 2>&1 > ~/logs/nohup.out";
			py = "python3";
			shd = "shutdown";
			off = "poweroff";
			update = "nix flake update --flake ~/.dotfiles/.config/nixos";
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
		# 4242 #lan mouse
	];
	networking.firewall.allowedUDPPorts = [
		22000 21027 #syncthing
		# 4242 #lan mouse
	];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;
	networking.nftables.enable = true;
	#networking.firewall.interfaces."lo".allowed = true;

	#virtualisation.docker.enable = true;
	#virtualisation.docker.autoPrune.enable = true;



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

