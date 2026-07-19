import os


CONFIG_PATH = "/home/hypoxie/.config/hypr/colors.lua"


def gen(config: dict):
    result = "return {\n"
    for key, color in config.items():
        result += f"{key} = \"rgba({color[1:]}FF)\",\n"
    result += "}"
    with open(CONFIG_PATH, "w") as file:
        file.write(result)
    os.system("hyprctl reload")
