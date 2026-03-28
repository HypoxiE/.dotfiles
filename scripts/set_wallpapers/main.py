#!/usr/bin/env python3

import sys
from pathlib import Path
import subprocess
import random
import argparse
import time
import json

from datetime import date

#(holiday_id, weight)
def check_holidays(date) -> list[tuple[str, int]]:
	season_weight = 5
	big_holidays_weight = 25

	holiday_flag = []
	if (25 <= date.day and date.month == 12) or (date.day <= 10 and date.month == 1):
		holiday_flag.append(("new_year", big_holidays_weight))
	
	if (date.day == 31 and date.month == 10):
		holiday_flag.append(("halloween", big_holidays_weight))

	if (14 <= date.day <= 17 and date.month == 2):
		holiday_flag.append(("valentine_day", big_holidays_weight))
	
	if date.month == 12 or date.month == 1 or date.month == 2:
		holiday_flag.append(("winter", season_weight))
	if 3 <= date.month <= 5:
		holiday_flag.append(("spring", season_weight))
	if 6 <= date.month <= 8:
		holiday_flag.append(("summer", season_weight))
	if 9 <= date.month <= 11:
		holiday_flag.append(("autumn", season_weight))

	return holiday_flag

import logging
logging.basicConfig(
    filename="/tmp/set_wallpapers.log",
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)


gcol = ["go-colors-picker"]

# Папка с обоями
WALLPAPER_DIR = Path.home() / "images" / "wallpapers"
SUPPORTED_EXT = [".jpg", ".jpeg", ".png", ".gif", ".webp"]

def pick_image(base_name: str) -> Path:
	"""
	Ищет изображение по базовому имени, игнорируя .conf.
	Если .conf рядом нет — запускает gcol и завершает программу.
	"""
	# ищем все картинки с base_name
	candidates = [f for f in WALLPAPER_DIR.glob(f"{base_name}.*") if f.suffix.lower() in SUPPORTED_EXT]

	if not candidates:
		# fallback на .jpg
		fallback = WALLPAPER_DIR / f"{base_name}.jpg"
		if fallback.exists():
			candidates = [fallback]
		else:
			print(f"❌ File {base_name} not found.")
			sys.exit(1)

	# случайный выбор
	img = random.choice(candidates)

	# проверяем конфиг
	conf_file = img.with_suffix(".conf")
	if not conf_file.exists():
		print(f"⚠️  Конфиг {conf_file} не найден, запускаем gcol...")
		subprocess.run([*gcol, str(img)])

	return img

def pick_random_image() -> Path:
	files = {file: 1 for file in (WALLPAPER_DIR / "universal").iterdir() if file.suffix.lower() in SUPPORTED_EXT}
	for holid, weight in check_holidays(date.today()):
		hol_dir = WALLPAPER_DIR / holid
		if not hol_dir.exists() or not hol_dir.is_dir():
			continue

		file_names = {i.name: i for i in files.keys()}

		for file in hol_dir.iterdir():
			if file.name in file_names.keys():
				if files[file_names[file.name]] < weight:
					files[file_names[file.name]] = weight
			else:
				if file.suffix.lower() in SUPPORTED_EXT:
					files[file] = weight

	assert files
	img = random.choices(
		population=[f for f in files.keys()],
		weights=[w for w in files.values()],
		k=1
	)[0]

	img = WALLPAPER_DIR / "all" / img.name


	conf_file = img.with_suffix(".conf")
	if not conf_file.exists():
		print(f"⚠️  Конфиг {conf_file} не найден, запускаем gcol...")
		subprocess.run([*gcol, str(img)])
	
	return img

def wait_for_swww():
	while True:
		result = subprocess.run(["swww", "query"], capture_output=True)
		if result.returncode == 0:
			break
		time.sleep(0.1)

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("image", nargs="?", help="image path or name")
	parser.add_argument("-i", "--instant", action="store_true", help="instant wallpaper change")
	args = parser.parse_args()

	if args.image is None:
		# случайное изображение
		img_path = pick_random_image()
	else:
		arg = Path(args.image)
		if arg.is_file():
			img_path = arg
			# проверяем .conf
			conf_file = img_path.with_suffix(".conf")
			if not conf_file.exists():
				print(f"⚠️  Конфиг {conf_file} не найден, запускаем gcol...")
				subprocess.run([*gcol, str(img_path)])
		else:
			# поиск по базовому имени
			img_path = pick_image(arg.stem)

	# вызываем Python скрипт
	result = subprocess.run(
		[
			"python3",
			"/home/hypoxie/scripts/set_themes/main.py",
			"-i",
			str(img_path)
		],
		capture_output=True,
		text=True
	)
	logging.info(f"image path: {img_path}")
	logging.info(f"set_theme is ready: {result}")

	if not args.instant:
		pos = subprocess.check_output(["hyprctl", "cursorpos"]).decode().strip()
		x, y = map(int, pos.split(","))

		monitors_json = subprocess.check_output(["hyprctl", "monitors", "-j"])
		monitors = json.loads(monitors_json)

		mon = monitors[0]
		screen_width = mon["width"]
		screen_height = mon["height"]

		cmd = ["swww", "img", str(img_path), "--transition-type", "grow", "--transition-pos", f"{x},{screen_height-y}", "--transition-duration", "0.5", "--transition-fps", "100"]
		result = subprocess.run(cmd, capture_output=True, text=True)
		logging.info(f"wallpaper set: {result}")

	result = subprocess.run(["eww", "reload"])
	logging.info(f"eww reloaded: {result}")
	workspace_json = subprocess.check_output(["hyprctl", "activeworkspace", "-j"])
	workspace_json = json.loads(workspace_json)
	
	subprocess.run(["eww", "update", f"active_workspace={workspace_json["id"]}"])
	result = subprocess.run(["hyprctl", "reload"])
	logging.info(f"hyprland reloaded: {result}")


	if args.instant:
		wait_for_swww()
		cmd = ["swww", "img", str(img_path), "--transition-type", "none", "--transition-duration", "0"]#, "--outputs", "eDP-1,HDMI-A-1"
		result = subprocess.run(cmd, capture_output=True, text=True)
		logging.info(f"wallpaper set: {result}")

if __name__ == "__main__":
	main()
