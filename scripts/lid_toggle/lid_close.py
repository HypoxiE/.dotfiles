import os
import subprocess

import constants
from get_brightness import set_brightness, set_brightness_precent


def lid_is_opened():
	if os.path.exists(constants.TMP_FILE):
		b = open(constants.TMP_FILE).read().strip()
		set_brightness(int(b))
	else:
		set_brightness_precent(58)