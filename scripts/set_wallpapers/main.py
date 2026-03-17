#!/usr/bin/env python3

import sys
from pathlib import Path
import subprocess
import random
import argparse
import time
import json

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
	files = [f for f in WALLPAPER_DIR.iterdir() if f.suffix.lower() in SUPPORTED_EXT]
	assert files
	img = random.choice(files)

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
