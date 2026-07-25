import os


CONFIG_PATH = "/home/hypoxie/.config/fuzzel/colors.ini"


def gen(config: dict):
    result = "[colors]\n"
    result += f"background={config['main_color'][1:]}ff\n"
    result += f"text={config['text_color'][1:]}ff\n"
    result += f"match={config['secondary_color'][1:]}ff\n"
    result += f"selection={config['secondary_color'][1:]}ff\n"
    result += f"selection-text={config['text_color'][1:]}ff\n"
    result += f"border={config['icons_color'][1:]}ff\n"

    with open(CONFIG_PATH, "w") as file:
        file.write(result)
