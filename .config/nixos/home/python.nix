{ pkgs ? import <nixpkgs> {} }:

pkgs.python313.withPackages (ps: with ps; [
	numpy
	pandas
	requests
	flask
])