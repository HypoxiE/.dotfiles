#!/usr/bin/env python3
import sys
from pathlib import Path
import subprocess
import random

gcol = ["gocp"]

# Папка с обоями
WALLPAPER_DIR = Path.home() / "images" / "wallpapers"
SUPPORTED_EXT = [".jpg", ".png", ".gif", ".webp"]

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

def main():
	if len(sys.argv) < 2:
		# случайное изображение
		img_path = pick_random_image()
	else:
		arg = Path(sys.argv[1])
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

	# устанавливаем обои
	subprocess.run(["swww", "img", str(img_path)])

	# вызываем Python скрипт
	subprocess.run([
		"python3",
		"/home/hypoxie/scripts/set_themes/main.py",
		"-i",
		str(img_path)
	])

if __name__ == "__main__":
	main()
