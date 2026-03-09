{ config, pkgs, lib, ... }:

let
	# генерация рабочих столов 1..10
	workspaces = map toString (lib.range 1 10);

	workspaceBinds =
		map (n: "$mainMod, ${n}, workspace, ${n}") workspaces;

	moveWorkspaceBinds =
		map (n: "$mainMod SHIFT, ${n}, movetoworkspace, ${n}") workspaces;

	monitorList = [
		{ name = "eDP-1";  conf = "1920x1080@60.01,0x0,1"; }
		{ name = "HDMI-A-1"; conf = "1920x1080@60.01,auto,1,mirror,eDP-1"; }
	];

	monitors =
		map (m: "${m.name},${m.conf}") monitorList;

	browserRules =
		map (c: "workspace 2 silent,class:${c}") [
			"firefox"
			"vivaldi-stable"
		];
	editorRules =
		map (c: "workspace 3 silent,class:${c}") [
			"code-oss"
			"code"
			"Code"
		];
	chatRules =
		map (c: "workspace 9 silent,class:${c}") [
			"org.telegram.desktop"
			"com.ayugram.desktop"
			"discord-canary"
			"discord"
			"legcord"
		];

in
{
	wayland.windowManager.hyprland = {
		enable = true;

		settings = {

		################
		# MONITORS
		################
		monitor = monitors;

		################
		# VARIABLES
		################
		"$terminal" = "kitty";
		"$fileManager" = "dolphin";
		"$menu" = "wofi --show drun --gtk-dark --style ~/.config/wofi/style.css";

		"$mainMod" = "SUPER";

		################
		# AUTOSTART
		################
		exec-once = [
			"clipse -listen &"
			"wl-clip-persist --clipboard regular &"
			"swww-daemon & python3 ~/scripts/set_wallpapers/main.py --instant"
			"hyprmodify & udiskie &"
			"swaync &"
		];

		################
		# GENERAL
		################
		general = {
			gaps_in = 5;
			gaps_out = "60,10,10,10";
			border_size = 5;
			layout = "dwindle";
		};

		################
		# INPUT
		################
		input = {
			kb_layout = "us,ru";
			kb_options = "grp:win_space_toggle";
			numlock_by_default = true;
		};

		################
		# KEYBINDS
		################
		bind =
			[
				"SUPER&SHIFT, code:24, exit"
				"SUPER&SHIFT, Return, exec, $terminal"
				"ALT_L, F4, killactive"

				"$mainMod, left, movefocus, l"
				"$mainMod, right, movefocus, r"
				"$mainMod, up, movefocus, u"
				"$mainMod, down, movefocus, d"
			]
			++ workspaceBinds
			++ moveWorkspaceBinds;

		################
		# WINDOW RULES
		################
		windowrule =
			[
				"suppressevent maximize,class:.*"
				"workspace 8 silent,class:steam"
				"workspace 10 silent,class:Spotify"
			]
			++ browserRules
			++ editorRules
			++ chatRules;

		};

		extraConfig = ''
			source = ~/.config/hypr/colors.conf
		'';
	};
}