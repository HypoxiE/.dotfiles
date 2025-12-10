from pathlib import Path

from constants import BRIGHTNESS_FILE, MAX_BRIGHTNESS_FILE




def get_current_brightness() -> int:
	with BRIGHTNESS_FILE.open("r") as f:
		return int(f.read().strip())

def get_max_brightness() -> int:
	with MAX_BRIGHTNESS_FILE.open("r") as f:
		return int(f.read().strip())

def get_current_brightness_precent() -> float:
	return get_current_brightness() / get_max_brightness() * 100

def set_brightness(brightness: int):
	brightness = max(0, min(get_max_brightness(), brightness))

	try:
		with BRIGHTNESS_FILE.open("w") as f:
			f.write(str(brightness))
		print(f"Яркость установлена на {get_current_brightness_precent():.1f}% ({brightness}/{get_max_brightness()})")
	except PermissionError:
		print("Ошибка: недостаточно прав. Нужно запускать с root или дать права на запись в /sys/class/backlight/.")

def set_brightness_precent(percent: float):
	max_val = get_max_brightness()
	new_val = int(max_val * percent / 100)
	set_brightness(new_val)