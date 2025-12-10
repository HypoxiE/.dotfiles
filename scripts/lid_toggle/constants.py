from pathlib import Path


TMP_FILE = "/home/hypoxie/scripts/lid_toggle/brightness_save"

BACKLIGHT_PATH = Path("/sys/class/backlight/amdgpu_bl1")
BRIGHTNESS_FILE = BACKLIGHT_PATH / "brightness"
MAX_BRIGHTNESS_FILE = BACKLIGHT_PATH / "max_brightness"