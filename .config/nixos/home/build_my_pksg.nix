{ pkgs }:

let
	input.hyprmodify = pkgs.buildGoModule {
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

	input.go-colors-picker = pkgs.buildGoModule {
		pname = "go-colors-picker";
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

	input.screenland = pkgs.rustPlatform.buildRustPackage {
		pname = "screenland";
		version = "0.1.0";

		src = pkgs.fetchgit {
			url = "https://github.com/Andrewkoro105/screenland.git";
			rev = "641bfe9562991381ab9ffa69fa0a5e98dc158ac7";
			hash = "sha256-2lTkGLctf58YOdVhm3qAM+APAES2hl/X/SnONLssLqk=";
		};

		cargoHash = "sha256-l74/Nv2PCer666n9ugvK30s+lxNeC1xGOH1kDlKYb+s=";

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
	input.wallpaper-manager = pkgs.rustPlatform.buildRustPackage {
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
	inherit input;
}
