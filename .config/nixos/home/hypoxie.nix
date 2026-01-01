{ config, pkgs, spicetify-nix, ... }:

let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  #nixpkgs.config.allowUnfree = true;

  home.username = "hypoxie";
  home.homeDirectory = "/home/hypoxie";

  home.stateVersion = "25.11";

  programs.git.settings = {
    enable = true;
    user.name = "HypoxiE";
    user.email = "kosmaer42@gmail.com";
  };

  programs.spicetify = {
    enable = true;
    #theme = spicePkgs.themes.catppuccin;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
    ];
  };

  programs.firefox = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "simple-tab-groups@drive4ik" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/simple-tab-groups/latest.xpi";
          installation_mode = "force_installed";
        };
        "simple-translate@sienori" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/simple-translate/latest.xpi";
          installation_mode = "force_installed";
        };
        preferences = {
          
        };
      };
    };
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.newtabpage.activity-stream.default.sites" = "";
        "browser.startup.page" = 3;
      };

    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      img = "chafa";
    };
  };
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "macchiato";
        accent = "maroon";
      };
      name = "Papirus-Dark";
    };
    theme = {
      package = pkgs.gruvbox-dark-gtk;
      name = "gruvbox-dark";
    };
#    theme = {
#        name = "catppuccin-macchiato-mauve-compact";
#        package = pkgs.catppuccin-gtk.override {
#          accents = ["mauve"];
#          variant = "macchiato";
#          size = "compact";
#        };
#    };
    colorScheme = "dark";
    gtk2.extraConfig = ''
      gtk-cursor-theme-size = 12
      gtk-cursor-theme-name = "capitaine-cursors"
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-cursor-theme-size = 12;
      gtk-cursor-theme-name = "capitaine-cursors";
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
      };
  };
  qt = {
      enable = true;
      platformTheme.name = "gtk";
  };
  
  home.packages = with pkgs; [
    chafa
    ncdu # disk analiser
    unzip
    calc

    #communication
    ayugram-desktop
    legcord

    #games
    steam
    prismlauncher

    #keyboard
    qmk
    usbutils
    via
    keychron-udev-rules

    #programming
    arduino-cli

    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "save-as-root";
          publisher = "yy0931";
          version = "1.12.0";
          sha256 = "fGYqT7emOL14p3LfAaR4CaxUkTYHbopIOc25TC248r4=";
        }
        {
          name = "vscode-latex";
          publisher = "mathematic";
          version = "1.3.0";
          sha256 = "/mbMpel9JHmSh0GN/wIbFi/0voaQBxGn0SueZlUFZUc=";
        }
        {
          name = "yuck";
          publisher = "eww-yuck";
          version = "0.0.3";
          sha256 = "DITgLedaO0Ifrttu+ZXkiaVA7Ua5RXc4jXQHPYLqrcM=";
        }
        {
          name = "vscode-arduino-community";
          publisher = "vscode-arduino";
          version = "0.7.2";
          sha256 = "/HdPJ6LBnyPhz7jeJ0MLRXO2L3bcAzM7J65nKsXsacY=";
        }
      ];
    })
  ];
}
