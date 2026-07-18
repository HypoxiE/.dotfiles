{
  terminal,
  menu,
}: let
  # codeA = "code:38";
  # codeB = "code:56";
  codeC = "code:54";
  # codeD = "code:40";
  # codeE = "code:26";
  codeF = "code:41";
  # codeG = "code:42";
  # codeH = "code:43";
  # codeI = "code:31";
  # codeJ = "code:44";
  # codeK = "code:45";
  # codeL = "code:46";
  codeM = "code:58";
  # codeN = "code:57";
  # codeO = "code:32";
  codeP = "code:33";
  codeQ = "code:24";
  codeR = "code:27";
  codeS = "code:39";
  codeT = "code:28";
  # codeU = "code:30";
  codeV = "code:55";
  codeW = "code:25";
  # codeX = "code:53";
  # codeY = "code:29";
  # codeZ = "code:52";

  mainMod = "SUPER";
in [
  # system actions
  {
    key = "SUPER + SHIFT + ${codeQ}";
    action = "hl.dsp.exit()";
  }
  {
    key = "ALT + F4";
    action = "hl.dsp.window.close()";
  }

  # workspaces navigation
  {
    key = "${mainMod} + ${codeS}";
    action = "hl.dsp.workspace.toggle_special(\"magic\")";
  }
  {
    key = "SUPER + CTRL + left";
    action = "hl.dsp.focus({ workspace = \"-1\" })";
  }
  {
    key = "SUPER + CTRL + right";
    action = "hl.dsp.focus({ workspace = \"+1\" })";
  }
  {
    key = "${mainMod} + mouse_down";
    action = "hl.dsp.focus({ workspace = \"+1\" })";
  }
  {
    key = "${mainMod} + mouse_up";
    action = "hl.dsp.focus({ workspace = \"-1\" })";
  }
  {
    key = "ALT + TAB";
    action = "function() hl.dispatch(hl.dsp.focus({workspace = previousWorkspace})) end";
  }
  {
    key = "${mainMod} + ${codeM}";
    action = "hl.dsp.focus({workspace = 1})";
  }

  #windows control
  {
    key = "${mainMod} + ${codeT}";
    action = "hl.dsp.window.float({ action = \"toggle\" })";
  }
  {
    key = "${mainMod} + ${codeF}";
    action = "hl.dsp.window.fullscreen()";
  }
  {
    key = "${mainMod} + ${codeP}";
    action = "hl.dsp.window.pseudo()";
  }
  {
    key = "${mainMod} + SHIFT + ${codeS}";
    action = "hl.dsp.window.move({ workspace = \"special:magic\" })";
  }
  {
    key = "${mainMod} + mouse:272";
    action = "hl.dsp.window.drag()";
  }
  {
    key = "${mainMod} + mouse:273";
    action = "hl.dsp.window.resize()";
  }
  {
    key = "${mainMod} + left";
    action = "hl.dsp.focus({ direction = \"l\" })";
  }
  {
    key = "${mainMod} + right";
    action = "hl.dsp.focus({ direction = \"r\" })";
  }
  {
    key = "${mainMod} + up";
    action = "hl.dsp.focus({ direction = \"u\" })";
  }
  {
    key = "${mainMod} + down";
    action = "hl.dsp.focus({ direction = \"d\" })";
  }
  {
    key = "${mainMod} + ${codeW}";
    action = "hl.dsp.submap(\"windowControl\")";
  }

  # programs run
  {
    key = "${mainMod} + ${codeR}";
    action = "hl.dsp.exec_cmd(\"${menu}\")";
  }
  {
    key = "SUPER + ${codeV}";
    action = "hl.dsp.exec_cmd(\"${terminal} --class clipse -e 'clipse'\")";
  }
  {
    key = "Print";
    action = "hl.dsp.exec_cmd(\"screenland\")";
  }
  {
    key = "SUPER + SHIFT + Return";
    action = "hl.dsp.exec_cmd(\"${terminal}\")";
  }
  {
    key = "ALT + F1";
    action = "hl.dsp.exec_cmd(\"~/scripts/set_wallpapers/main.py\")";
  }
  {
    key = "ALT + F6";
    action = "hl.dsp.exec_cmd(\"~/.config/hypr/autoclicker.sh\")";
  }
  {
    key = "ALT + ${codeC}";
    action = "hl.dsp.exec_cmd(\"hyprpicker --autocopy\")";
  }
  {
    key = "Scroll_Lock";
    action = "hl.dsp.exec_cmd(\"hyprlock\")";
  }
  {
    key = "ALT + F4";
    action = "hl.dsp.window.close()";
  }

  # function keys
  {
    key = "XF86AudioStop";
    action = "hl.dsp.exec_cmd(\"spotify\")";
  }
  {
    key = "XF86AudioPause";
    action = "hl.dsp.exec_cmd(\"playerctl play-pause\")";
    flags = {
      locked = true;
    };
  }
  {
    key = "XF86AudioPrev";
    action = "hl.dsp.exec_cmd(\"playerctl previous\")";
    flags = {
      locked = true;
    };
  }
  {
    key = "XF86AudioPlay";
    action = "hl.dsp.exec_cmd(\"playerctl play-pause\")";
    flags = {
      locked = true;
    };
  }
  {
    key = "XF86AudioNext";
    action = "hl.dsp.exec_cmd(\"playerctl next\")";
    flags = {
      locked = true;
    };
  }
  {
    key = "XF86Search";
    action = "hl.dsp.exec_cmd(\"firefox\")";
  }

  {
    key = "XF86AudioRaiseVolume";
    action = "hl.dsp.exec_cmd(\"pactl set-sink-volume 0 +2%\")";
    flags = {
      locked = true;
      repeating = true;
    };
  }
  {
    key = "XF86AudioLowerVolume";
    action = "hl.dsp.exec_cmd(\"pactl set-sink-volume 0 -2%\")";
    flags = {
      locked = true;
      repeating = true;
    };
  }

  {
    key = "XF86MonBrightnessUp";
    action = "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 2%+\")";
    flags = {
      locked = true;
      repeating = true;
    };
  }
  {
    key = "XF86MonBrightnessDown";
    action = "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 2%-\")";
    flags = {
      locked = true;
      repeating = true;
    };
  }
]
