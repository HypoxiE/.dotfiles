import os


CONFIG_PATH = "/home/hypoxie/scripts/clipboard_manager/colors.py"


def gen(config: dict):
    result = f"BACKGROUND = \"{config['main_color']}\"\n"
    result += f"TEXT=\"{config['text_color']}\"\n"
    result += f"BACKGROUND_SELECTED=\"{config['secondary_color']}\"\n"
    result += f"TEXT_SELECTED=\"{config['icons_color']}\"\n"
    result += f"BORDER=\"{config['text_color']}\"\n"

    with open(CONFIG_PATH, "w") as file:
        file.write(result)
