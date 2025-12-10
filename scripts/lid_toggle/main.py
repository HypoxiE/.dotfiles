import os, subprocess
import argparse
import time

import lid_open as lo, lid_close as lc

parser = argparse.ArgumentParser(description="Управление яркостью при закрытии/открытии крышки")
parser.add_argument("--state", choices=["open", "closed"], required=False, help="Состояние крышки")
parser.add_argument("--save-only", action="store_true", help="Только сохранить состояние")

args = parser.parse_args()

state = open("/proc/acpi/button/lid/LID/state").read().split()[-1]
if args.state:
	state = args.state

def main():
	global state
	if state == "closed":
		lo.lid_is_closed()

	elif state == "open":
		lc.lid_is_opened()

if __name__ == "__main__":
	if args.save_only:
		lo.lid_save_state()
	else:
		main()