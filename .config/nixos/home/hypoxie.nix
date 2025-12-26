{ config, pkgs, ... }:

{
  home.username = "hypoxie";
  home.homeDirectory = "/home/hypoxie";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.git.settings = {
    enable = true;
    user.name = "HypoxiE";
    user.email = "kosmaer42@gmail.com";
  };

  #programs.firefox = {
  #  enable = true;

  #  profiles.default = {
  #    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
  #      ublock-origin
  #      darkreader
  #    ];
  #  };
  #};

  home.packages = with pkgs; [
    htop
  ];
}
