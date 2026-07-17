{ config, pkgs, host, lib, ... }:

let
	range = start: end: builtins.genList (n: start + n) (end - start + 1);
	mod10 = n: if n == 10 then 0 else n;
	
	communicationClasses = [
		"org.telegram.desktop"
		"com.ayugram.desktop"
		"discord-canary"
		"discord"
		"legcord"
		"Legcord"
		"electron"
	];
	
	browserClasses = [
		"firefox"
		"vivaldi-stable"
	];
	
	editorClasses = [
		"code-oss"
		"code"
		"Code"
		"Emacs"
	];
	
	workspaceNumbers = range 1 10;
	
    A = "code:38";
    B = "code:56";
    C = "code:54";
    D = "code:40";
    E = "code:26";
    F = "code:41";
    G = "code:42";
    H = "code:43";
    I = "code:31";
    J = "code:44";
    K = "code:45";
    L = "code:46";
    M = "code:58";
    N = "code:57";
    O = "code:32";
    P = "code:33";
    Q = "code:24";
    R = "code:27";
    S = "code:39";
    T = "code:28";
    U = "code:30";
    V = "code:55";
    W = "code:25";
    X = "code:53";
    Y = "code:29";
    Z = "code:52";

	mainMod = "SUPER";

	terminal = "kitty";
	menu = "wofi --show drun --gtk-dark --style ~/.config/wofi/style.css";

    topGap = "60";
	bottomGap = "10";
    rightGap = "10";
	leftGap = "10";
    
in {
	wayland.windowManager.hyprland = {
		enable = true;
        # extraConfig = ''
        #     hl.on("hyprland.start", function()
        #         hl.exec_cmd("swww-daemon --no-cache")
        #         h1.exec_cmd("python3 ~/scripts/set_wallpapers/main.py --instant")
        #         h1.exec_cmd("swaync")
        #         h1.exec_cmd("hyprmodify")
        #         hl.exec_cmd("${
        #           if host == "hypoxlaptop"
        #           then "GDK_BACKEND=wayland eww daemon && eww open workspaces_bar && eww open metrics_laptop_bar && eww open time_bar"
        #           else "GDK_BACKEND=wayland eww daemon && eww open workspaces_bar && eww open metrics_pc_bar && eww open time_bar"
        #         }")
        #     end)
        # '';
		
		settings = {
            currentWorkspace = {
                _var = 1;
            };
            previousWorkspace = {
                _var = 1;
            };
            
			# source = "~/.config/hypr/colors.conf";
			
			################
			### МОНИТОРЫ ###
			################
			# monitor = [
			# 	"eDP-1,1920x1080@60.01,0x0,1"
			# 	"HDMI-A-1,1920x1080@74.97,0x0,1,mirror,eDP-1"#
			# ];
			
			#################
			### АВТОЗАПУСК ###
			#################
			# exec-once = [
			# 	"clipse -listen &"
			# 	"wl-clip-persist --clipboard regular &"
			# 	"swww-daemon --no-cache &"
			# 	"python3 ~/scripts/set_wallpapers/main.py --instant &"
			# 	"~/projects/ard_indicator/pc_monitor/target/release/pc_monitor &"
			# 	"hyprmodify & udiskie &"
			# 	"swaync &"
			# 	"legcord & env DESKTOPINTEGRATION=1 AyuGram -- &"
			# ] ++ 
			# (
			# 	if host == "hynix_" then
			# 		[]
			# 	else if host == "hypoxlaptop" then
			# 		["GDK_BACKEND=wayland eww daemon && eww open workspaces_bar && eww open metrics_laptop_bar && eww open time_bar"]
			# 	else
			# 		["GDK_BACKEND=wayland eww daemon && eww open workspaces_bar && eww open metrics_pc_bar && eww open time_bar"]
			# );

            on = [
                {
                    _args = [
                        "hyprland.start"
                        (lib.generators.mkLuaInline ''
                            function()
                                hl.exec_cmd("clipse -listen")
                                hl.exec_cmd("wl-clip-persist --clipboard regular")
                                hl.exec_cmd("awww-daemon --no-cache")
                                hl.exec_cmd("python3 ~/scripts/set_wallpapers/main.py --instant")
                                hl.exec_cmd("swaync")
                                hl.exec_cmd("udiskie")
                                hl.exec_cmd("${
                                    if host == "hypoxlaptop"
                                    then "GDK_BACKEND=wayland eww daemon && eww open workspaces_bar && eww open metrics_laptop_bar && eww open time_bar"
                                    else "GDK_BACKEND=wayland eww daemon && eww open workspaces_bar && eww open metrics_pc_bar && eww open time_bar"
                                }")
                            end
                        '')
                    ];
                }
                {
                    _args = [
                        "workspace.active"
                        (lib.generators.mkLuaInline ''
                            function(event)
                                previousWorkspace = currentWorkspace
                                currentWorkspace = event.id
                                hl.exec_cmd("eww update active_workspace=" .. currentWorkspace)
                            end
                        '')
                    ];
                }
            ];

            config = {
                general = {
                    gaps_in = 5;
                    gaps_out = {
                        # ${topGap},${rightGap},${bottomGap},${leftGap}"
                        top = topGap;
                        right = rightGap;
                        bottom = bottomGap;
                        left = leftGap;
                    };
                };
                decoration = {
                    rounding = 10;
                    rounding_power = 2;
                    active_opacity = 1.0;
                    inactive_opacity = 0.75;
                    shadow = {
                        enabled = true;
                        range = 4;
                        render_power = 3;
                        color = "rgba(1a1a1aee)";
                    };
                    blur = {
                        enabled = true;
                        size = 3;
                        passes = 1;
                        vibrancy = 0.1696;
                    };
                };
                animations = {
                    enabled = true;
                };
                misc = {
                    force_default_wallpaper = -1;
                    disable_hyprland_logo   = true;
                };
                input = {
                    kb_layout = "us,ru";
                    kb_variant = "";
                    kb_model = "";
                    kb_options = "grp:win_space_toggle";
                    kb_rules = "";
                    numlock_by_default = true;
                    follow_mouse = 1;
                    sensitivity = 0;
                    touchpad = {
                        natural_scroll = true;
                    };
                };
            };

            curve = [
                {
                    _args = [
                        "easeOutQuint"
                        {
                            type = "bezier";
                            points = [
                                [0.23 1]
                                [0.32 1]
                            ];
                        }
                    ];
                }
                {
                    _args = [
                        "easeInOutCubic"
                        {
                            type = "bezier";
                            points = [
                                [0.65 0.05]
                                [0.36 1]
                            ];
                        }
                    ];
                }
                {
                    _args = [
                        "linear"
                        {
                            type = "bezier";
                            points = [
                                [0 0]
                                [1 1]
                            ];
                        }
                    ];
                }
                {
                    _args = [
                        "almostLinear"
                        {
                            type = "bezier";
                            points = [
                                [0.5  0.5]
                                [0.75 1]
                            ];
                        }
                    ];
                }
                {
                    _args = [
                        "quick"
                        {
                            type = "bezier";
                            points = [
                                [0.15 0]
                                [0.1  1]
                            ];
                        }
                    ];
                }
            ];

            animation = [
                {
                    leaf = "global";
                    enabled = true;
                    speed = 10;
                    bezier = "default";
                }
                {
                    leaf = "border";
                    enabled = true;
                    speed = 5.39;
                    bezier = "easeOutQuint";
                }
                {
                    leaf = "windows";
                    enabled = true;
                    speed = 4.79;
                    bezier = "easeOutQuint";
                }
                {
                    leaf = "windowsIn";
                    enabled = true;
                    speed = 4.1;
                    bezier = "easeOutQuint";
                    style = "popin 87%";
                }
                {
                    leaf = "windowsOut";
                    enabled = true;
                    speed = 1.49;
                    bezier = "linear";
                    style = "popin 87%";
                }
                {
                    leaf = "fadeIn";
                    enabled = true;
                    speed = 1.73;
                    bezier = "almostLinear";
                }
                {
                    leaf = "fadeOut";
                    enabled = true;
                    speed = 1.46;
                    bezier = "almostLinear";
                }
                {
                    leaf = "fade";
                    enabled = true;
                    speed = 3.03;
                    bezier = "quick";
                }
                {
                    leaf = "layers";
                    enabled = true;
                    speed = 3.81;
                    bezier = "easeOutQuint";
                }
                {
                    leaf = "layersIn";
                    enabled = true;
                    speed = 4;
                    bezier = "easeOutQuint";
                    style = "fade";
                }
                {
                    leaf = "layersOut";
                    enabled = true;
                    speed = 1.5;
                    bezier = "linear";
                    style = "fade";
                }
                {
                    leaf = "fadeLayersIn";
                    enabled = true;
                    speed = 1.79;
                    bezier = "almostLinear";
                }
                {
                    leaf = "fadeLayersOut";
                    enabled = true;
                    speed = 1.39;
                    bezier = "almostLinear";
                }
                {
                    leaf = "workspaces";
                    enabled = true;
                    speed = 1.94;
                    bezier = "almostLinear";
                    style = "fade";
                }
                {
                    leaf = "workspacesIn";
                    enabled = true;
                    speed = 1.21;
                    bezier = "almostLinear";
                    style = "fade";
                }
                {
                    leaf = "workspacesOut";
                    enabled = true;
                    speed = 1.94;
                    bezier = "almostLinear";
                    style = "fade";
                }
                {
                    leaf = "zoomFactor";
                    enabled = true;
                    speed = 7;
                    bezier = "quick";
                }
            ];
			
			#############################
			### ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ ###
			#############################
			# env = [
			# 	"XCURSOR_SIZE,24"
			# 	"HYPRCURSOR_SIZE,24"
			# ];
			
			###################
			### РАЗРЕШЕНИЯ ###
			###################
			# permission = [
			# 	"/usr/(bin|local/bin)/grim, screencopy, allow"
			# ];
			
			# general = {
			# 	border_size = 5;
			# 	"col.active_border" = "$active_border_color_1 $active_border_color_2 45deg";
			# 	"col.inactive_border" = "$inactive_border_color_1 $inactive_border_color_2 45deg";
			# 	resize_on_border = false;
			# 	allow_tearing = false;
			# 	layout = "dwindle";
			# };
			
			# xwayland = {
			# 	force_zero_scaling = true;
			# };
			

			# dwindle = {
			# 	pseudotile = true;
			# 	preserve_split = true;
			# };
			
			# master = {
			# 	new_status = "master";
			# };
			
			
			# gesture  = "3, horizontal, workspace";
			
			# device = {
			# 	name = "epic-mouse-v1";
			# 	sensitivity = -0.3;
			# };
			
			bind = [
                {
                    _args = [
                        "SUPER + SHIFT + ${Q}"
                        (lib.generators.mkLuaInline "hl.dsp.exit()")
                    ];
                }
                {
                    _args = [
                        "SUPER + SHIFT + Return"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${terminal}\")")
                    ];
                }
                {
                    _args = [
                        "ALT + F4"
                        (lib.generators.mkLuaInline "hl.dsp.window.close()")
                    ];
                }
				# "${mainMod}, ${M}, workspace, 1"
				# "${mainMod}, ${T}, togglefloating,"
				# "${mainMod}, ${F}, fullscreen,"
                {
                    _args = [
                        "${mainMod} + ${R}"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${menu}\")")
                    ];
                }
				# "${mainMod}, ${P}, pseudo,"
				# "${mainMod} ALT_L, ${S}, togglesplit,"

				# "${mainMod}, left, movefocus, l"
				# "${mainMod}, right, movefocus, r"
				# "${mainMod}, up, movefocus, u"
				# "${mainMod}, down, movefocus, d"
				# "${mainMod}, ${H}, movefocus, l"
				# "${mainMod}, ${L}, movefocus, r"
				# "${mainMod}, ${K}, movefocus, u"
				# "${mainMod}, ${J}, movefocus, d"

				# "${mainMod} SHIFT, left, movewindow, l"
				# "${mainMod} SHIFT, right, movewindow, r"
				# "${mainMod} SHIFT, up, movewindow, u"
				# "${mainMod} SHIFT, down, movewindow, d"
				# "${mainMod} SHIFT, ${H}, movewindow, l"
				# "${mainMod} SHIFT, ${L}, movewindow, r"
				# "${mainMod} SHIFT, ${K}, movewindow, u"
				# "${mainMod} SHIFT, ${J}, movewindow, d"

				# "${mainMod} CTRL, ${H}, resizeactive, -50 0"
				# "${mainMod} CTRL, ${L}, resizeactive, 50 0"
				# "${mainMod} CTRL, ${K}, resizeactive, 0 -50"
				# "${mainMod} CTRL, ${J}, resizeactive, 0 50"

				# "${mainMod}, ${S}, togglespecialworkspace, magic"
				# "${mainMod} SHIFT, ${S}, movetoworkspace, special:magic"
				# "${mainMod}, mouse_down, workspace, e+1"
				# "${mainMod}, mouse_up, workspace, e-1"
				# "SUPER CTRL, left, workspace, -1"
				# "SUPER CTRL, right, workspace, +1"

                {
                    _args = [
                        "ALT + TAB"
                        (lib.generators.mkLuaInline ''
                            function()
                                hl.exec_cmd("hyprctl dispatch 'hl.dsp.focus({workspace = " .. previousWorkspace .. "})' ")
                            end
                        '')
                    ];
                }
				# "ALT_L, TAB, exec, echo \"prev_tag\" | socat - UNIX-CONNECT:/tmp/hyprmodify/hypr_read.sock"
				# "${mainMod}, ${H}, exec, echo \"hide_bar\" | socat - UNIX-CONNECT:/tmp/hyprmodify/hypr_read.sock"
                {
                    _args = [
                        "Print"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"screenland\")")
                    ];
                }
                {
                    _args = [
                        "SUPER + ${V}"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"${terminal} --class clipse -e 'clipse'\")")
                    ];
                }
				# "ALT_R, ${C}, exec, hyprpicker --autocopy"
				# ",Scroll_Lock, exec, hyprlock"
                {
                    _args = [
                        "XF86AudioStop"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"spotify\")")
                    ];
                }
				# ",XF86Search, exec, firefox"
				# "ALT_R, F1, exec, ~/scripts/set_wallpapers/main.py"
				# "SUPER SHIFT, X, exec, pkill Xwayland"

				# #autoclicker
				# "ALT_R, F6, exec, ~/.config/hypr/autoclicker.sh"

                {
                    _args = [
                        "${mainMod} + mouse:272"
                        (lib.generators.mkLuaInline "hl.dsp.window.drag()")
                        { mouse = true; }
                    ];
                }
                {
                    _args = [
                        "${mainMod} + mouse:273"
                        (lib.generators.mkLuaInline "hl.dsp.window.resize()")
                        { mouse = true; }
                    ];
                }
                {
                    _args = [
                        "XF86AudioRaiseVolume"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pactl set-sink-volume 0 +2%\")")
                        { locked = true; repeating = true; }
                    ];
                }
                {
                    _args = [
                        "XF86AudioLowerVolume"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"pactl set-sink-volume 0 -2%\")")
                        { locked = true; repeating = true; }
                    ];
                }
                {
                    _args = [
                        "XF86MonBrightnessUp"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 2%+\")")
                        { locked = true; repeating = true; }
                    ];
                }
                {
                    _args = [
                        "XF86MonBrightnessDown"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 2%-\")")
                        { locked = true; repeating = true; }
                    ];
                }
                {
                    _args = [
                        "XF86AudioNext"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl next\")")
                        { locked = true; }
                    ];
                }
                {
                    _args = [
                        "XF86AudioPause"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
                        { locked = true; }
                    ];
                }
                {
                    _args = [
                        "XF86AudioPlay"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
                        { locked = true; }
                    ];
                }
                {
                    _args = [
                        "XF86AudioPrev"
                        (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl previous\")")
                        { locked = true; }
                    ];
                }
			]
			
			# Генерация workspace переключений (1-10)
			++ (map (n: {
                _args = [
                    "${mainMod} + ${toString (mod10 n)}"
                    (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = ${toString n} })")
                ];
            }) workspaceNumbers)
			# Генерация перемещений на workspace (1-10)
            ++ (map (n: {
                _args = [
                    "${mainMod} + SHIFT + ${toString (mod10 n)}"
                    (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = ${toString n} })")
                ];
            }) workspaceNumbers);

            window_rule = [
                # {
                #     name = "silent open";
                    
                # }
                {
                    name = "clipboard";
                    match = {
                        class = "^(clipse)$";
                    };
                    float = true;
                    no_anim = true;
                    size = ["monitor_w * 0.4" "monitor_h * 0.6"];
                    stay_focused = true;
                    opacity = 1;
                }
                {
                    name = "save as";
                    match = {
                        title = "Save As";
                    };
                    float = true;
                }
                {
                    name = "opacity ${terminal}";
                    match = {
                        class = "${terminal}";
                    };
                    opacity = 0.85;
                }
                {
                    name = "browsers on workspace";
                    match = {
                        class = "^(${lib.concatStringsSep "|" browserClasses})$";
                    };
                    workspace = "2 silent";
                }
                {
                    name = "editors on workspace";
                    match = {
                        class = "^(${lib.concatStringsSep "|" editorClasses})$";
                    };
                    workspace = "3 silent";
                }
                {
                    name = "messagers on workspace";
                    match = {
                        class = "^(${lib.concatStringsSep "|" communicationClasses})$";
                    };
                    workspace = "9 silent";
                }
                {
                    name = "fix ayugram media viewer";
                    match = {
                        class = "^(com.ayugram.desktop)$";
                        title = "^(Media viewer)$";
                    };
                    fullscreen = true;
                }
            ];
			
			##############################
			### ОКНА И РАБОЧИЕ СТОЛЫ ###
			##############################
			#windowrulev2 = [
			#	"workspace silent current, class:.*"
			#];
			# windowrule = ["workspace silent current, class:.*"]++[
			# 	#"monitor HDMI-A-1, match:title screenland-HDMI-A-1"
			# 	#"monitor DP-1, match:title screenland-DP-1"

			# 	"suppressevent maximize, class:.*"
			# 	"nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
			# ]
			# # Генерация правил для workspace 8 (steam)
			# ++ [ "workspace 8 silent,class:steam" ]
			
			# ++ (map (class: "workspace 9 silent,class:${class}") workspace9Classes)
			# ++ [
			# 	"float, class:^(com.ayugram.desktop)$, title:^(Media viewer)$"
			# 	"fullscreen, class:^(com.ayugram.desktop)$, title:^(Media viewer)$"
			# 	"workspace 9 silent,title:^(.*Legcord.*)$"
			# ]
			# ++ [
			# 	"fullscreen, class:^(Matplotlib)$"
			# ]

			
			# # Генерация правил для workspace 10 (spotify)
			# ++ [ "workspace 10 silent,class:Spotify" ];
			
		};
	};
}
















