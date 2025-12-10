
import os


CONFIG_PATH = "/home/hypoxie/.config/eww/colors.scss"

def gen(config: dict):
	result = ""
	for key, color in config.items():
		result += f"${key}: {color};\n"
		
	with open(CONFIG_PATH, "w") as file:
		file.write(result)
	os.system("eww reload")