{ pkgs }:

let
	spicetify = pkgs.callPackage ./spicetify-nix { };

	miku-cursor = pkgs.stdenv.mkDerivation {
		name = "hatsune-miku-cursor";

		src = pkgs.fetchFromGitHub {
			owner = "supermariofps";
			repo = "hatsune-miku-windows-linux-cursors";
			rev = "471ff88156e9a3dc8542d23e8cae4e1c9de6e732";
			sha256 = "sha256-HCHo4GwWLvjjnKWNiHb156Z+NQqliqLX1T1qNxMEMfE=";
		};

		installPhase = ''
		mkdir -p $out/share/icons
		cp -r miku-cursor-linux $out/share/icons/Hatsune\ Miku
		'';
	};

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

in
{
	inherit spicetify miku-cursor catgirl-downloader;
}