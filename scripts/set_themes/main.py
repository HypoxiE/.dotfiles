#!/usr/bin/env python3

import json
from pathlib import Path
import sys

import generate_hypr_config as ghc
import generate_eww_config as gec

if __name__ == "__main__":
	assert len(sys.argv) >= 2

	config_path = Path()
	if sys.argv[1] == "-i":
		image_path = Path(sys.argv[2])
		config_path = Path(str(image_path.parent)  + "/" +  str(image_path.stem) + ".conf")
	else:
		config_path = Path(sys.argv[1])

	with open(str(config_path), 'r') as fp:
		conf = json.load(fp)
	
	ghc.gen(conf["hyprland"])
	gec.gen(conf["eww"])
