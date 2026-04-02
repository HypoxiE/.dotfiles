{ config, pkgs, spicetify-nix, stylix, host, ... }:

let
	spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

	catgirl-downloader =
		let
			pythonEnv = pkgs.python3.withPackages (ps: with ps; [
				pygobject3
				requests
			]);
		in
			pkgs.stdenv.mkDerivation rec {
				pname = "catgirl-downloader";
				version = "0.0.0";

				src = pkgs.fetchgit {
					url = "https://github.com/NyarchLinux/CatgirlDownloader";
					rev = "6793a5ac678397a1d865d4e1d7769f7a7024ae0c";
					hash = "sha256-+RyQOgqPZN3AnVdd5mtgppQ/z51VIEeEsiW2RFTnVbk=";
				};

				nativeBuildInputs = with pkgs; [
					meson
					ninja
					pkg-config
					gettext
					wrapGAppsHook3
					desktop-file-utils
					appstream-glib
				];

				buildInputs = with pkgs; [
					pythonEnv
					gtk4
					glib
					gobject-introspection
					libadwaita
				];

				configurePhase = ''
					meson setup build --prefix=$out -Dauto_features=enabled -Dwrap_mode=nodownload
				'';

				buildPhase = "meson compile -C build";
				installPhase = "meson install -C build";

				postInstall = ''
				wrapProgram $out/bin/catgirldownloader \
					--set PATH ${pythonEnv}/bin:$PATH \
					--prefix GI_TYPELIB_PATH : \
					${pkgs.glib.out}/lib/girepository-1.0 \
					${pkgs.gtk4.out}/lib/girepository-1.0 \
					${pkgs.gdk-pixbuf.out}/lib/girepository-1.0 \
					${pkgs.pango.out}/lib/girepository-1.0 \
					${pkgs.harfbuzz.out}/lib/girepository-1.0
				'';
			};

	hyprmodify = pkgs.buildGoModule {
		pname = "hyprmodify";
		version = "0.0.0";

		src = pkgs.fetchgit {
			url = "https://github.com/HypoxiE/hyprmodify.git";
			rev = "be192477cb9ccba38a134bc3addfb19afc0b1834";
			hash = "sha256-yy2NZ5k8MakWulU+omohO0m+EZbVOwFq/IEH01Hu1zo=";
		};

		vendorHash = null;

		meta = with pkgs.lib; {
			description = "Hyprland utility";
			license = licenses.mit;
			platforms = platforms.linux;
		};
	};
	gocp = pkgs.buildGoModule {
		pname = "gocp";
		version = "0.0.0";

		src = pkgs.fetchgit {
			url = "https://github.com/HypoxiE/go-colors-picker.git";
			rev = "47de3c18c8d84bbae4cc5fe65cecdc0dfe4708df";
			hash = "sha256-qe0nnoM3+WKjykUkusZrvHjS7UZqj9ajw6OQK9wBc0E=";
		};

		vendorHash = "sha256-ktU6xnJLlkUFKnmiYOyPwHioGTUVnV7nPIkrC6d4bhU=";

		doCheck = false;

		meta = with pkgs.lib; {
			description = "Color pick utility";
			license = licenses.mit;
			platforms = platforms.linux;
		};
	};
	screenland = pkgs.rustPlatform.buildRustPackage {
		pname = "screenland";
		version = "0.1.0";

		src = pkgs.fetchgit {
			url = "https://github.com/Andrewkoro105/screenland.git";
			rev = "3d225da1cae6123cd4a351a68b6b5c8a7cea489b";
			hash = "sha256-LUkaVaIbtgvlH4CIqWDpkLZrfH/BJ6Lhq3F8PSk40BY=";
		};

		cargoHash = "sha256-IczJlrP8gZqFYv8qFvwob4wFTYpZxWZE+SKE5OUXW+4=";

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
	wallpaper-manager = pkgs.rustPlatform.buildRustPackage {
		pname = "wallpaper-manager";
		version = "0.1.0";

		src = pkgs.fetchgit {
			url = "https://github.com/HypoxiE/wallpapers_manager";
			rev = "42d7ffcbdc7a981e217df9ed87ce05154afa319d";
			hash = "sha256-JeJ43vyB26Oq2reEslBSkkyL3BHYUS8khCzmK3En89E=";
		};

		cargoHash = "sha256-eOwHehAhEyatqRL1oXS+MOZ41A9PeR6W7gkj+ssQ/ng=";

		buildInputs = with pkgs; [
			pkg-config
			openssl
		];

		propagatedBuildInputs = with pkgs; [
			libxkbcommon
			wayland
		];

		meta = with pkgs.lib; {
			description = "My wallpapers management program";
			license = licenses.mit;
			platforms = platforms.linux;
		};

		nativeBuildInputs = with pkgs; [
			makeWrapper
		];

		postFixup = ''
			wrapProgram $out/bin/wallpaper_manager \
				--prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
				pkgs.wayland
				pkgs.libxkbcommon
			]}

			mkdir -p $out/share/applications
			cat > $out/share/applications/wallpaper-manager.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Wallpaper Manager
Comment=Manage your wallpapers
Exec=$out/bin/wallpaper_manager
Icon=preferences-desktop-wallpaper
Terminal=false
Categories=Utility;X-GNOME-Utilities;
EOF
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

	programs.vscode = {
		enable = true;
		#package = pkgs.vscode.fhs;

		profiles.default.extensions = with pkgs.vscode-extensions; [
			bbenoist.nix
			ms-vscode.cpptools
			ms-vscode.cmake-tools

			rust-lang.rust-analyzer
			golang.go

			ms-python.python
			james-yu.latex-workshop
		]++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
			{
				name = "save-as-root";
				publisher = "yy0931";
				version = "1.12.0";
				sha256 = "fGYqT7emOL14p3LfAaR4CaxUkTYHbopIOc25TC248r4=";
			}
			{
				name = "yuck";
				publisher = "eww-yuck";
				version = "0.0.3";
				sha256 = "DITgLedaO0Ifrttu+ZXkiaVA7Ua5RXc4jXQHPYLqrcM=";
			}

		];
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
		catgirl-downloader
		wallpaper-manager
		screenland
		hyprmodify
		gocp

		chafa
		jq # for system monitor
		ncdu # disk analiser
		kdePackages.dolphin # file manager
		unzip
		calc
		libreoffice
		gimp
		krita
		ydotool # автокликер

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
		bruno # http requests
		gcc gdb cmake fmt

		#vtubing
		inochi-session
		inochi-creator
		openseeface

		#ssh
		gnupg
	];
}
