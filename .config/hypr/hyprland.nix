{
  host,
  lib,
  ...
}: let
  range = start: end: builtins.genList (n: start + n) (end - start + 1);
  mod10 = n:
    if n == 10
    then 0
    else n;

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

  mainMod = "SUPER";

  terminal = "kitty";
  menu = "wofi --show drun --gtk-dark --style ~/.config/wofi/style.css";

  topGap = "60";
  bottomGap = "10";
  rightGap = "10";
  leftGap = "10";

  binds = import ./binds.nix {inherit terminal menu;};
in {
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      currentWorkspace = {
        _var = 1;
      };
      previousWorkspace = {
        _var = 1;
      };

      # source = "~/.config/hypr/colors.conf";

      # monitor = [
      # 	"eDP-1,1920x1080@60.01,0x0,1"
      # 	"HDMI-A-1,1920x1080@74.97,0x0,1,mirror,eDP-1"#
      # ];

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
                  hl.exec_cmd("legcord")
                  hl.exec_cmd("env DESKTOPINTEGRATION=1 AyuGram --")
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
        {
          _args = [
            "keybinds.submap"
            (lib.generators.mkLuaInline ''
              function(name)
                  local label = "D"
                  if name == "windowControl" then
                      label = "W"
                  end

                  hl.exec_cmd("eww update binds_submap_active=" .. label)
              end
            '')
          ];
        }
      ];

      config = {
        general = {
          gaps_in = 5;
          gaps_out = {
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
          disable_hyprland_logo = true;
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
              points = [[0.23 1] [0.32 1]];
            }
          ];
        }
        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [[0.65 0.05] [0.36 1]];
            }
          ];
        }
        {
          _args = [
            "linear"
            {
              type = "bezier";
              points = [[0 0] [1 1]];
            }
          ];
        }
        {
          _args = [
            "almostLinear"
            {
              type = "bezier";
              points = [[0.5 0.5] [0.75 1]];
            }
          ];
        }
        {
          _args = [
            "quick"
            {
              type = "bezier";
              points = [[0.15 0] [0.1 1]];
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
      env = [
        {_args = ["XCURSOR_SIZE" "24"];}
        {_args = ["HYPRCURSOR_SIZE" "24"];}
      ];

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

      bind =
        (map (n: {
            _args = [
              "${mainMod} + ${toString (mod10 n)}"
              (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = ${toString n} })")
              {submap_universal = true;}
            ];
          })
          workspaceNumbers)
        ++ (map (n: {
            _args = [
              "${mainMod} + SHIFT + ${toString (mod10 n)}"
              (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = ${toString n} })")
              {submap_universal = true;}
            ];
          })
          workspaceNumbers)
        ++ (map (
            {
              key,
              action,
              flags ? {},
            }: {
              _args = [
                key
                (lib.generators.mkLuaInline action)
                flags
              ];
            }
          )
          binds);

      define_submap = [
        {
          _args = [
            "windowControl"
            (lib.generators.mkLuaInline ''
              function()
                  hl.bind("CTRL + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true}), { repeating = true })
                  hl.bind("CTRL + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true}), { repeating = true })
                  hl.bind("CTRL + up", hl.dsp.window.resize({ x = 0, y = 50, relative = true}), { repeating = true })
                  hl.bind("CTRL + down", hl.dsp.window.resize({ x = 0, y = -50, relative = true}), { repeating = true })

                  hl.bind("SHIFT + right", hl.dsp.window.move({ direction = "r" }))
                  hl.bind("SHIFT + left", hl.dsp.window.move({ direction = "l" }))
                  hl.bind("SHIFT + up", hl.dsp.window.move({ direction = "u" }))
                  hl.bind("SHIFT + down", hl.dsp.window.move({ direction = "d" }))

                  hl.bind("right", hl.dsp.focus({ direction = "r" }))
                  hl.bind("left", hl.dsp.focus({ direction = "l" }))
                  hl.bind("up", hl.dsp.focus({ direction = "u" }))
                  hl.bind("down", hl.dsp.focus({ direction = "d" }))

                  hl.bind("escape", hl.dsp.submap("reset"))
                  hl.bind("catchall", function() end)
              end
            '')
          ];
        }
      ];

      window_rule = [
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
          name = "fix matplotlib";
          match = {class = "^(Matplotlib)$";};
          fullscreen = true;
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
          name = "games on workspace";
          match = {class = "^(steam)$";};
          workspace = "8 silent";
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
        {
          name = "spotify on workspace";
          match = {class = "^(Spotify)$";};
          workspace = "10 silent";
        }
      ];
    };
  };
}
