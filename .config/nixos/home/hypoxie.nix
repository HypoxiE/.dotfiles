{ config, pkgs, spicetify-nix, host, ... }:

let
	spicetify = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

	my-pkgs = import ./build_my_pksg.nix { inherit pkgs; };
	other-pkgs = import ./build_pksg.nix { inherit pkgs; };
	proton-gw = pkgs.fetchurl {
		url = "https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-11.0-2/dwproton-11.0-2-x86_64.tar.xz";
		sha256 = "sha256-h8agHudNEYccm55l2M2TN6YvRvQHEqnEdj+NVxUXlds=";
	};
	proton-ge = pkgs.fetchurl {
		url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton10-34/GE-Proton10-34.tar.gz";
		sha256 = "sha256-UcWAtmqDPHOZj+APBxfurFcZdlQECi8u1RiePuaNdz0=";
	};
in
{
	imports = [
		../../hypr/hyprland.nix
	];

	home.username = "hypoxie";
	home.homeDirectory = "/home/hypoxie";

	home.stateVersion = "26.05";

	home.activation.installProtonGWGE = config.lib.dag.entryAfter ["writeBoundary"] ''
		export PATH=${pkgs.lib.makeBinPath [ pkgs.gnutar pkgs.gzip pkgs.xz ]}:$PATH

		mkdir -p $HOME/.steam/root/compatibilitytools.d
		tar -xvJf ${proton-gw} -C $HOME/.steam/root/compatibilitytools.d
		tar -xvf ${proton-ge} -C $HOME/.steam/root/compatibilitytools.d
	'';

	programs.git = {
		enable = true;
		settings = {
			user = {
				name = "HypoxiE";
				email = "kosmaer42@gmail.com";
			};
			init.defaultBranch = "main";
			credential.helper = "store";
			credential.useHttpPath = true;
		};
	};

	programs.obs-studio = {
		enable = true;
		plugins = with pkgs.obs-studio-plugins; [
			obs-multi-rtmp
		];
	};

	programs.spicetify = {
		enable = true;
		#theme = spicePkgs.themes.catppuccin;
		enabledExtensions = with spicetify.extensions; [
			adblock
			hidePodcasts
		];
	};

	programs.firefox = {
		enable = true;

		policies = {
	    	DisableTelemetry = true;
            DisableFirefoxAccounts = true;
            DisableAccounts = true;
            PasswordManagerEnabled = false;
            OfferToSaveLogins = false;

            ExtensionSettings = {
                "*".installation_mode = "blocked";
                "uBlock0@raymondhill.net" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                    installation_mode = "force_installed";
                };
                "simple-tab-groups@drive4ik" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/simple-tab-groups/latest.xpi";
                    installation_mode = "force_installed";
                };
                "simple-translate@sienori" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/simple-translate/latest.xpi";
                    installation_mode = "force_installed";
                };
                "jid0-bnmfwWw2w2w4e4edvcdDbnMhdVg@jetpack" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab-reloader/latest.xpi";
                    installation_mode = "force_installed";
                };
                "keepassxc-browser@keepassxc.org" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
                    installation_mode = "force_installed";
                };
                "webextension@metamask.io" = {
                    install_url = "https://addons.mozilla.org/firefox/downloads/latest/ether-metamask/latest.xpi";
                    installation_mode = "force_installed";
                };
                preferences = {

                };
		    };
		};
		profiles.default = {
		    id = 0;
            name = "default";
            isDefault = true;
            settings = {
                "browser.tabs.closeWindowWithLastTab" = false;
                "browser.newtabpage.activity-stream.default.sites" = "";
                "browser.startup.page" = 3;
            };
		};
        nativeMessagingHosts = [
            pkgs.keepassxc
        ];
	};

	programs.zsh = {
		enable = true;
		shellAliases = {
			img = "chafa";
			hevel = "swc-launch hevel";
		};
	};

	services.emacs = {
		enable = true;
		client.enable = true;
	};
	programs.emacs = {
		enable = true;
		extraPackages = epkgs: [
			      epkgs.doom-themes
			      epkgs.use-package
				  epkgs.editorconfig
                  epkgs.orderless
				  epkgs.vertico
				  epkgs.yaml-mode
				  epkgs.consult
				  epkgs.marginalia
				  epkgs.corfu
		];
	};

	# programs.vscode = {
	# 	enable = true;
	# 	#package = pkgs.vscode.fhs;

	# 	profiles.default.extensions = with pkgs.vscode-extensions; [
	# 		ms-toolsai.jupyter
	# 		ms-toolsai.vscode-jupyter-cell-tags
	# 		ms-toolsai.vscode-jupyter-slideshow
	# 		ms-toolsai.jupyter-keymap
	# 		#ms-toolsai.jupyter-renderers
	# 		
	# 		bbenoist.nix
	# 		arrterian.nix-env-selector
	# 		ms-vscode.cpptools
	# 		ms-vscode.cmake-tools

	# 		rust-lang.rust-analyzer
	# 		golang.go

	# 		ms-python.python
	# 		ms-python.vscode-pylance
	# 		ms-python.debugpy

	# 		james-yu.latex-workshop
	# 	]++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
	# 		{
	# 			name = "save-as-root";
	# 			publisher = "yy0931";
	# 			version = "1.12.0";
	# 			sha256 = "fGYqT7emOL14p3LfAaR4CaxUkTYHbopIOc25TC248r4=";
	# 		}
	# 		{
	# 			name = "yuck";
	# 			publisher = "eww-yuck";
	# 			version = "0.0.3";
	# 			sha256 = "DITgLedaO0Ifrttu+ZXkiaVA7Ua5RXc4jXQHPYLqrcM=";
	# 		}
	# 		{
	# 			name = "csv";
	# 			publisher = "repreng";
	# 			version = "1.3.0";
	# 			sha256 = "wrbrArOWHxpjJh8/TQ4YJpz6B3F+WgI5C2bSGUYmfPM=";
	# 		}
	# 	];
	# };

	home.sessionVariables = {
		XCURSOR_THEME = "Hatsune Miku";
		XCURSOR_SIZE = "24";
		ELECTRON_OZONE_PLATFORM_HINT = "auto";
	};

	gtk = {
		enable = true;
		cursorTheme = {
			name = "Hatsune Miku";
			package = other-pkgs.input.miku-cursor;
			size = 24;
		};
		iconTheme = {
			#package = pkgs.catppuccin-papirus-folders.override {
			#	flavor = "macchiato";
			#	accent = "maroon";
			#};
			#name = "Papirus-Dark";
			package = pkgs.tela-icon-theme;
			name = "Tela";
		};
		
		theme = {
			package = pkgs.orchis-theme;
			name = "Orchis-Dark";
		};
		colorScheme = "dark";
		gtk2.extraConfig = ''
			gtk-cursor-theme-size = 12
			gtk-cursor-theme-name = "capitaine-cursors"
		'';
		gtk3.extraConfig = {
			gtk-application-prefer-dark-theme = 1;
			gtk-cursor-theme-size = 12;
			gtk-cursor-theme-name = "capitaine-cursors";
		};
		gtk4.extraConfig = {
			Settings = ''
				gtk-application-prefer-dark-theme=1
			'';
		};
	};
	xdg.mimeApps = {
		enable = true;
		defaultApplications = {
			"application/pdf" = [ "firefox.desktop" ];
			"text/plain" = [ "code.desktop" ];
		};
	};

	systemd.user.services.ydotoold = {
		Unit = {
			Description = "ydotool daemon (user)";
		};

		Service = {
			ExecStart = "${pkgs.ydotool}/bin/ydotoold";
			Restart = "always";
			RestartSec = 1;
		};

		Install = {
			WantedBy = [ "default.target" ];
		};
	};

	home.packages = with pkgs; [
		(import ./python.nix { inherit pkgs; })

		other-pkgs.input.miku-cursor
		other-pkgs.input.catgirl-downloader
		hevel
		neuswc
		neuwld
        nixos-generators

		my-pkgs.input.hyprmodify
		my-pkgs.input.go-colors-picker
		my-pkgs.input.screenland
		my-pkgs.input.wallpaper-manager

		chafa
		jq # for system monitor
		ncdu # disk analiser
		kdePackages.dolphin # file manager
        keepassxc # password manager
		unzip
		calc
		libreoffice
		gimp
		krita
		ydotool # автокликер
		cups pantum-driver # принтеры
		zathura #pdf viewer
		virt-manager
		virt-viewer
		qemu

		#wayland
		wl-clipboard
		wl-clip-persist
		clipse
		hyprland
		hyprlock hyprpicker eww awww
		wayland wayland-protocols
		kitty
		wofi
		swaynotificationcenter
		remmina # Для подключения к виртуалке винды

		#communication
		ayugram-desktop
		legcord

		#games
		steam
		protonup-qt
		prismlauncher

		#keyboard
		qmk
		usbutils
		via
		keychron-udev-rules
		lan-mouse

		#programming
		texlive.combined.scheme-full
		arduino
		rustc
		rust-analyzer
		cargo
		openscad
		android-tools
		mtkclient
		bruno # http requests
		gcc gdb cmake fmt ninja

		#vtubing
		inochi-session
		inochi-creator
		openseeface

		#ssh
		gnupg
	];
}
