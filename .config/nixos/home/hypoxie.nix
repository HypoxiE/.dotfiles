{ config, pkgs, spicetify-nix, stylix, host, ... }:

let
	spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

	screenland = pkgs.rustPlatform.buildRustPackage {
		pname = "screenland";
		version = "0.1.0";

		src = pkgs.fetchgit {
			url = "https://github.com/HypoxiE/screenland.git";
			rev = "80c803f88313d05a7223f9c0f950bc79609ac280";
			hash = "sha256-6nz7J9HuRZMUJHlSV3hVmjM4z3vJMzpFiF/R4Dythv0=";
		};

		cargoHash = "sha256-fQhYWP25gqUqxe9ixI0/q1O3jt4FrCqxUZdqxlwbJsI=";

		buildInputs = with pkgs; [
			pkg-config
			openssl
		];

		propagatedBuildInputs = with pkgs; [
			libxkbcommon
			wayland
			zenity
			libGL
			vulkan-loader
			mesa
		];

		meta = with pkgs.lib; {
			description = "Screen capture tool";
			license = licenses.mit;
			platforms = platforms.linux;
		};

		nativeBuildInputs = with pkgs; [
			makeWrapper
		];

		postFixup = ''
			wrapProgram $out/bin/screenland \
				--prefix PATH : ${pkgs.lib.makeBinPath [
				pkgs.zenity
			]} \
				--prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
				pkgs.wayland
				pkgs.libxkbcommon
				pkgs.vulkan-loader
				pkgs.mesa
				pkgs.libGL
			]}
		'';
	};
in
{
	imports = [
		../../hypr/hyprland.nix
	];

	home.username = "hypoxie";
	home.homeDirectory = "/home/hypoxie";

	home.stateVersion = "25.11";

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
		enabledExtensions = with spicePkgs.extensions; [
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

		ExtensionSettings = {
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
	};

	programs.bash = {
		enable = true;
		shellAliases = {
		img = "chafa";
		};
	};
	gtk = {
		enable = true;
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

	home.packages = with pkgs; [
		screenland
		chafa
		jq # for system monitor
		ncdu # disk analiser
		unzip
		calc
		libreoffice
		gimp
		krita

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
		arduino
		rustc
		rust-analyzer
		cargo
		openscad
		android-tools
		mtkclient

		#vtubing
		inochi-session
		inochi-creator
		openseeface

		#ssh
		gnupg

		(vscode-with-extensions.override {
		vscodeExtensions = with vscode-extensions; [
			bbenoist.nix
		] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
			{
				name = "save-as-root";
				publisher = "yy0931";
				version = "1.12.0";
				sha256 = "fGYqT7emOL14p3LfAaR4CaxUkTYHbopIOc25TC248r4=";
			}
			{
				name = "latex-workshop";
				publisher = "james-yu";
				version = "10.12.2";
				sha256 = "6VXlsMtAPFROYlmYJdHj54fo1J0LC4UJbzI00cuuwhk=";
			}
			{
				name = "yuck";
				publisher = "eww-yuck";
				version = "0.0.3";
				sha256 = "DITgLedaO0Ifrttu+ZXkiaVA7Ua5RXc4jXQHPYLqrcM=";
			}
			{
				name = "cpptools-extension-pack";
				publisher = "ms-vscode";
				version = "1.3.1";
				sha256 = "HbI0UdN8uwHS2MPH1SGZhxNaN18cWzjMyWYcgVE7FjY=";
			}
			{
				name = "cpptools";
				publisher = "ms-vscode";
				version = "1.29.3";
				sha256 = "wDHdpW6vV183RrMrssCGFW6w5IrqnlvIZO1dr5T6Syg=";
			}
			{
				name = "cpptools-themes";
				publisher = "ms-vscode";
				version = "2.0.0";
				sha256 = "YWA5UsA+cgvI66uB9d9smwghmsqf3vZPFNpSCK+DJxc=";
			}
			{
				name = "cpp-devtools";
				publisher = "ms-vscode";
				version = "0.2.0";
				sha256 = "cTUwhnwZ51gh89mLoNI/mVITor2KbZrhCG9M8gHbOjc=";
			}
			{
				name = "cmake-tools";
				publisher = "ms-vscode";
				version = "1.22.27";
				sha256 = "pMAJ2pk32KX5vc3QUqXIRTlBQuvOR0EiHpIfQe5aTwU=";
			}
			{
				name = "rust-analyzer";
				publisher = "rust-lang";
				version = "0.3.2743";
				sha256 = "rQO6suFU81fEzMCGzjugxnj8hs/Xv+26gAPQqwmaBts=";
			}
			{
				name = "python";
				publisher = "ms-python";
				version = "2026.0.0";
				sha256 = "se9kL7KmBZSh6R5f91XKey3CWLQVQNtEEbaHQ4AZAuo=";
			}
			{
				name = "go";
				publisher = "golang";
				version = "0.52.2";
				sha256 = "8g+r4Mv06Bx1W3yAXWVbtz1B/gXPcRdmaV0tPkTP6Gk=";
			}
		];
		})
	];
}
