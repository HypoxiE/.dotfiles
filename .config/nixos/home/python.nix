{ pkgs ? import <nixpkgs> {} }:

pkgs.python313.withPackages (ps: with ps; [
	numpy
	pandas
	requests
	json5
	typer #arguments
])