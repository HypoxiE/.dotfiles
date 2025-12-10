import subprocess
import constants
from get_brightness import get_current_brightness, set_brightness_precent

def lid_is_closed():
	lid_save_state()
	set_brightness_precent(0)

def lid_save_state():
	current_brightness = get_current_brightness()
	if current_brightness != 0:
		open(constants.TMP_FILE, "w").write(str(current_brightness))