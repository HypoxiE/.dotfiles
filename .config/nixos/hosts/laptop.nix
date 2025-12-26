# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  #home-manager.users.hypoxie = import /home/hypoxie/.config/nixos/home/hypoxie.nix;

  #Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.initrd.systemd.enable = true;
  #boot.initrd.enable = true;
  #boot.loader.systemd-boot.useUnifiedKernelImages = true;
  boot.loader.grub.configurationLimit = 5;
  boot.loader.grub = {
    enable = true;
    #devices = [ "/dev/disk/by-id/nvme-XPG_GAMMIX_S11_Pro_2P082LQ8B2UF" ];
    devices = [ "nodev" ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "hynix"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.wireless.iwd.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  networking.proxy = {
    default = "socks5://127.0.0.1:10808";
    httpProxy = "http://127.0.0.1:10808";
    httpsProxy = "http://127.0.0.1:10808";
    noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  #console = {
  #  font = "cyr-sun16";
  #  keyMap = "ru";
  #  useXkbConfig = false; # use xkb.options in tty.
  #};

  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # Configure keymap in X11
  #services.xserver.xkb.layout = "us,ru";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  
  services.xray = {
    enable = true;
    settingsFile = "/etc/xray/config.json";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hypoxie = {
    isNormalUser = true;
    home = "/home/hypoxie";
    extraGroups = [ "wheel" "video" "input" "networkmanager" ]; # Enable ‘sudo’ for the user.
    # packages = with pkgs; [
    #   tree
    # ];
    password = "12345678";
  };

  fileSystems = {

    "/" = {
      device = "/dev/disk/by-uuid/369cc362-1f13-4acb-ae0e-eb25e52533b3";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/98d9730f-2cd0-46c5-9a1b-64ea2e75a1c3";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/46FD-E9EC";
      fsType = "vfat";
      options = [ "noatime" "umask=0077" ];
    };
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/974d917d-6a53-4d1b-949c-4f84fbff742b"; } ];

  programs.firefox.enable = true;
  programs.hyprland.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    gcc
    pam
    socat
    gnumake
    wl-clipboard
    adwaita-icon-theme

    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    tree
    iwd
    wget
    gtk3 # Необходимо для запуска gui приложений
    wev # Для получения кейкодов клавиш
    neofetch
    git
    zoxide
    xray
    # for screenshots
    grim
    slurp

    go
    python3
    texlive.combined.scheme-full

    stow
    clipse

    hyprland
    hyprpicker
    eww
    swww
    wayland
    wayland-protocols
    kitty
    wofi

    ayugram-desktop
    #spicetify
    firefox
    steam

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
      ];
    })
  ];
  fonts.packages = with pkgs; [
    #noto-fonts
    #noto-fonts-cjk-sans
    #noto-fonts-color-emoji
    #liberation_ttf
    #fira-code
    #fira-code-symbols
    #mplus-outline-fonts.githubRelease
    #dina-font
    #proggyfonts


    #material-icons
    material-symbols
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  environment.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";

    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      scol = "python3 /home/hypoxie/scripts/set_themes/main.py";
      wset = "/home/hypoxie/scripts/set_wallpapers/main.py";

      rebuild="sudo nixos-rebuild switch --flake ~/.config/nixos#laptop";
      rebuildr="sudo nixos-rebuild switch --flake ~/.config/nixos#laptop && reboot";
    };

    shellInit = ''
      eval "$(${pkgs.zoxide}/bin/zoxide init bash)"
    '';
  };

  #boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      nvidiaBusId = "PCI:01:00.0";
    };
  };
 

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

