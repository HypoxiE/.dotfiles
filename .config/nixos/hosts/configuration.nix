# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  host ? "default",
  ...
}: let
  # go-login = pkgs.buildGoModule {
  #   pname = "go-login";
  #   version = "0.0.0";
  #   src = pkgs.fetchgit {
  #     url = "https://github.com/HypoxiE/go-login-system.git";
  #     rev = "de035b15e75a7c52dd915375f64f7c095184f432";
  #     hash = "sha256-ZbockZFesNu+l6QY3SV+50xB6WVnQdd7iTDEDf7xx8k=";
  #   };
  #   vendorHash = "sha256-ith7A1fSk42DWQQiFItynpO2fKAfQm+tesAPILszwDs=";
  #   buildInputs = with pkgs; [
  #     pam
  #   ];
  #   nativeBuildInputs = with pkgs; [
  #     pkg-config
  #     makeWrapper
  #   ];
  #   env = {
  #     CGO_ENABLED = 1;
  #   };
  #   postFixup = ''
  #     wrapProgram $out/bin/go-login \
  #     	--prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [pkgs.pam]}
  #   '';
  #   meta = with pkgs.lib; {
  #     description = "Console login program for system";
  #     license = licenses.mit;
  #     platforms = platforms.linux;
  #   };
  # };
  scriptsDir = ../../../scripts;
  scripts = builtins.attrNames (builtins.readDir scriptsDir);
  proxyAddress = "127.0.0.1:10800";
  tunDevice = "tun0";
in {
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.trusted-users = ["root" "hypoxie"];
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  environment.etc = builtins.listToAttrs (map (name: {
      name = name;
      value = {
        source = "${scriptsDir}/${name}";
      };
    })
    scripts);

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  #Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  #boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  powerManagement.enable = true;
  #boot.initrd.enable = true;
  #boot.loader.systemd-boot.useUnifiedKernelImages = true;
  ##############################################
  # boot.extraModprobeConfig = ''              #
  #   # Intel 7265 фиксы                       #
  #   options iwlwifi power_save=0             #
  #   options iwlwifi power_scheme=1           #
  #   options iwlwifi uapsd_disable=1          #
  #                                            #
  #   # если будут зависания — раскомментируй: #
  #   options iwlwifi disable_11n=1            #
  # '';                                        #
  ##############################################
  boot.loader.grub = {
    enable = true;
    configurationLimit = 5;
    devices = ["nodev"];
    efiSupport = true;
    efiInstallAsRemovable = true;
    extraEntries = ''
      menuentry "Shutdown" {
      	echo "Shutting down..."
      	halt --no-apm
      	poweroff
      }
    '';

    theme = let
      baseTheme = pkgs.fetchFromGitHub {
        owner = "NyarchLinux";
        repo = "Nyarch-Grub-Theme";
        rev = "8cb88c7ad161ebc8e72fe6c7b1f70cf0f511d639";
        sha256 = "sha256-i77XGqIkECO2+Vw6ntZ1DVKPt42lPYjJU/qysL7fjDs=";
      };
    in
      pkgs.runCommand "custom-grub-theme" {} ''
        mkdir -p $out
        mkdir -p $out/images

        cp -r ${baseTheme}/Nyarch-theme/. $out/

        install -Dm644 ${../grub_textures/background.png} $out/background.png
        install -Dm644 ${../grub_textures/progress_highlight_c.png} $out/images/progress_highlight_c.png
      '';
  };
  boot.loader.grub.memtest86.enable = true;
  boot.tmp.useTmpfs = true;
  boot.tmp.zramSettings.zram-size = "min(ram / 2, 512)";

  networking.hostName = host;

  # systemd.mounts = [
  #   {
  #     what = "192.168.1.100:/data/shared";
  #     where = "/shared";
  #     type = "nfs";
  #     options = "nfsvers=4.2,noatime";
  #   }
  # ];

  # systemd.automounts = [
  #   {
  #     where = "/shared";
  #     wantedBy = ["multi-user.target"];
  #   }
  # ];

  # fileSystems."/shared" = {
  #   device = "192.168.1.100:/data/shared";
  #   fsType = "nfs";

  #   options = [
  #     "nfsvers=4.2"
  #     "x-systemd.automount"
  #     "noatime"
  #     "nofail"
  #     "noauto"

  #     "x-systemd.mount-timeout=5s"
  #     "x-systemd.idle-timeout=60"
  #   ];
  # };

  systemd.tmpfiles.rules = [
    "d /swap 0755 root root -"
    "d /shared 2775 root shared -"

    "d /var/lib/lucx-ui 0750 root root -"
    "d /var/lib/lucx-ui/cert 0750 root root -"
    "d /var/lib/lucx-ui/acme 0750 root root -"
  ];

  imports = [./specific/specific-hynix.nix ./specific/specific-laptop.nix];

  services.flatpak.enable = true;

  # Configure network connections interactively with nmcli or nmtui.
  #networking = {
  #	wireless.iwd.enable = true;
  #	networkmanager = {
  #		enable = false;
  #		wifi.backend = "iwd";
  #	};
  #};
  networking = {
    wireless.iwd = {
      enable = true;

      settings = {
        General = {
          EnableNetworkConfiguration = true;
        };

        Station = {
          PowerSave = false;
        };
      };
    };
  };

  networking.bridges.whonix-br.interfaces = [];
  networking.interfaces.whonix-br.useDHCP = false;
  networking.firewall.interfaces.whonix-br.allowedTCPPorts = [];
  networking.firewall.interfaces.whonix-br.allowedUDPPorts = [];

  boot.kernel.sysctl = {
    "net.ipv6.conf.whonix-br.disable_ipv6" = 1;
    "net.bridge.bridge-nf-call-iptables" = 0;
    "net.bridge.bridge-nf-call-ip6tables" = 0;
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";
  # time.timeZone = "Asia/Jakarta";

  # Configure network proxy if necessary
  networking.proxy = {
    # default = "socks5h://10.245.48.119:65000";
    # httpProxy = "http://10.245.48.119:65001";
    # httpsProxy = "http://10.245.48.119:65001";
    # default = "socks5://127.0.0.1:10800";
    # httpProxy = "http://127.0.0.1:10800";
    # httpsProxy = "http://127.0.0.1:10800";
    # noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = ["ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8"];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.printing = {
    enable = true;
    drivers = [pkgs.pantum-driver];
  };
  # systemd.services."getty@tty2".enable = true;
  # systemd.services."getty@tty2".serviceConfig = {
  # 	ExecStart = pkgs.lib.mkForce [
  # 		""
  # 		"${pkgs.util-linux}/bin/agetty --skip-login --noissue --noclear --login-program ${go-login}/bin/go-login %I $TERM"
  # 	];
  # 	Type = "idle";
  # 	NoNewPrivileges = "no";
  # };
  # services.getty.extraArgs = ["--skip-login" "--noissue" "--noclear"];
  # services.getty.loginProgram = "${go-login}/bin/go-login";
  # systemd.units."getty@tty2.service".serviceConfig = {
  # 	NoNewPrivileges = "no";
  # };
  # systemd.services."getty@".serviceConfig = {
  # 	ExecStart = [
  # 		""
  # 		"${pkgs.util-linux}/bin/agetty --skip-login --noissue --noclear --login-program ${pkgs.util-linux}/bin/login -- ${go-login}/bin/go-login %I $TERM"
  # 	];
  # 	Type = "idle";
  # 	NoNewPrivileges = "no";
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.shared = {
    gid = 987;
  };
  users.groups.davfs2 = {};

  users.users.davfs2 = {
    isSystemUser = true;
    group = "davfs2";
  };

  users.users.hypoxie = {
    isNormalUser = true;
    shell = pkgs.zsh;
    home = "/home/hypoxie";
    uid = 1000;
    extraGroups = ["libvirtd" "kvm" "wheel" "video" "input" "networkmanager" "dialout" "uucp" "wireshark" "shared" "davfs2" "docker"];
    password = "12345678";
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0860", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d030", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="d038", MODE="0666"
  '';
  services.udisks2.enable = true;
  hardware.uinput.enable = true;

  services.acpid = {
    enable = true;
  };
  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
    usePercentageForPolicy = true;
    percentageCritical = 10;
    percentageAction = 5;
  };
  systemd = {
    services = {
      upower = {
        wantedBy = ["graphical.target"];
      };
      file_caching_server = {
        description = "File Caching Server";
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          ExecStart = "${pkgs.python3.withPackages (ps:
            with ps; [
              flask
              requests
            ])}/bin/python /etc/file_caching_server/main.py";

          Restart = "always";
          RestartSec = 5;
        };
      };
    };
  };
  services.power-profiles-daemon.enable = true;

  programs.bash.enable = false;
  programs.hyprland.enable = true;
  programs.steam.enable = true;
  programs.xwayland.enable = true;
  # programs.starship.enable = true;
  # programs.zoxide.enable = true;
  # programs.home-manager.enable = true;
  programs.nixvim = {
    enable = true;
    plugins.web-devicons.enable = true;

    plugins = {
      nvim-tree.enable = true;
      telescope.enable = true;

      overseer = {
        enable = true;
      };
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = ["python" "LaTeX"];
        };
      };
      lsp.enable = true;
      toggleterm.enable = true;
    };

    keymaps = [
      {
        mode = "t";
        key = "<C-t>";
        action = "<C-\\><C-n>:ToggleTerm<CR>";
      }
      {
        mode = "n";
        key = "<C-t>";
        action = ":ToggleTerm<CR>";
      }
      {
        mode = "n";
        key = "<C-n>";
        action = ":NvimTreeToggle<CR>";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = ":nohlsearch<CR>";
      }
      {
        mode = "n";
        key = "<F5>";
        action = ":w | silent !xelatex %:p<CR>";
      }
      {
        mode = "n";
        key = "<leader>c";
        action = "<cmd>lua if vim.o.clipboard == 'unnamedplus' then vim.o.clipboard = '' else vim.o.clipboard = 'unnamedplus' end<CR>";
      }
    ];

    opts = {
      number = true;
      relativenumber = true;

      expandtab = false;
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 4;

      cursorline = true;
      signcolumn = "yes";
      clipboard = "unnamedplus";
    };
  };
  programs.neovim.defaultEditor = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  #programs.nix-ld.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    #go-login

    #libs
    qemu
    qemu-user
    pkg-config

    rclone
    sops
    age

    socat
    gnumake
    adwaita-icon-theme
    pulseaudio # регулировка звука
    playerctl # управление музыкой
    brightnessctl
    ddcutil # яркость
    acpid # выключение экрана
    dnsmasq

    #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    emacs
    yazi
    tree
    htop
    iwd # wifi
    bluez # bluetooth
    wget # для web запросов
    gtk3 # Необходимо для запуска gui приложений
    wev # Для получения кейкодов клавиш
    fastfetch
    git
    zoxide
    fzf # для поиска
    xray
    nftables

    go
    python3
    gcc

    stow
    OVMF
    virtiofsd
    udiskie
    mangohud
    qbittorrent
  ];

  fonts.packages = with pkgs; [
    material-symbols
    liberation_ttf
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  services.syncthing = {
    enable = true;
    user = "hypoxie";
    dataDir = "/home/hypoxie";
    configDir = "/home/hypoxie/.config/syncthing";
  };

  environment.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";

    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  programs.bash = {
    shellAliases = {
      scol = "${config.environment.etc."set_themes".source}/main.py";
      wset = "${config.environment.etc."set_wallpapers".source}/main.py";

      nohup = "nohup 2>&1 > ~/logs/nohup.out";
      update = "nix flake update --flake ~/.dotfiles/.config/nixos";

      py = "python3";
      venv = "source venv/bin/activate";

      vim = "nvim";
      code = "nvim";

      shd = "shutdown";
      off = "poweroff";
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      scol = "${config.environment.etc."set_themes".source}/main.py";
      wset = "${config.environment.etc."set_wallpapers".source}/main.py";

      nohup = "nohup 2>&1 > ~/logs/nohup.out";
      update = "nix flake update --flake ~/.dotfiles/.config/nixos";
      no-proxy = "unset http_proxy https_proxy no_proxy all_proxy ftp_proxy";

      py = "python3";
      venv = ''
        if [ -d "venv" ]; then
            source venv/bin/activate
        elif [ -d ".venv" ]; then
            source .venv/bin/activate
        else
            printf "ERROR: venv not found!\n"
        fi
      '';
      cvenv = "python -m venv .venv";

      vim = "nvim";
      code = "nvim";

      gita = "git add .";
      gitc = "git commit -m";
      gits = "git status";

      shd = "shutdown";
      off = "poweroff";
      hb = "sudo systemctl hibernate";
    };

    shellInit = ''
      fastfetch
    '';

    interactiveShellInit = ''
      bindkey -e
      bindkey "^[[3~" delete-char
      tabs -4
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      function rebuild {
      	if [ $# -gt 0 ]; then
      		commit_msg="$*"
      		git -C ~/.dotfiles add . && git -C ~/.dotfiles commit -m "$commit_msg"
      	fi

      	local bats=(/sys/class/power_supply/BAT*(N))

      	if (( ''${#bats} > 0 )); then
      	    echo "detected laptop"
      	    sudo nixos-rebuild switch --flake ~/.dotfiles/.config/nixos#laptop
      	else
      	    echo "detected pc"
      	    sudo nixos-rebuild switch --flake ~/.dotfiles/.config/nixos#pc
      	fi
      }

      function files {
      	local dir
      	if [ -n "$1" ]; then
      		dir=$(zoxide query -l "$1" | fzf --height 40% --reverse)
      	else
      		dir=$(zoxide query -l | fzf --height 40% --reverse)
      	fi

      	if [ -n "$dir" ] && [ -d "$dir" ]; then
      		cd "$dir"
      	fi
      }
      open() {
      	xdg-open "$@" & disown
      }
    '';

    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [
      22000 #syncthing
      2095 #sing-box
      10801 #tor socks proxy
      2053
      5081 #file caching server
      8000 #base opened
      22 #openssh
    ];
    allowedUDPPorts = [
      22000
      21027 #syncthing
      8000 # base opened
    ];
    checkReversePath = "loose";
    trustedInterfaces = ["virbr*" "Mihomo"];
  };

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.nftables.enable = true;

  #networking.firewall.interfaces."lo".allowed = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  # virtualisation.oci-containers = {
  #   backend = "docker";
  #   containers = {
  #     s-ui = {
  #       image = "docker.io/alireza7/s-ui:v1.4.2";
  #       autoStart = true;
  #       ports = [
  #         "10800:10800"
  #         "10801:10801"
  #         "2095:2095"
  #       ];
  #       volumes = [
  #         "/home/hypoxie/s-ui-data:/app/db"
  #       ];
  #     };
  #   };
  # };
  virtualisation.oci-containers = {
    backend = "docker";

    containers.lucx-ui = {
      image = "ghcr.io/alexeylcp/lucx-ui:latest";
      autoStart = true;

      ports = [
        "10800:10800"
        "10801:10801"
        "2053:2053"
      ];

      volumes = [
        "/var/lib/lucx-ui:/etc/x-ui"
        "/var/lib/lucx-ui/cert:/root/cert"
        "/var/lib/lucx-ui/acme:/root/.acme.sh"
      ];

      environment = {
        XRAY_VMESS_AEAD_FORCED = "false";
        XUI_ENABLE_FAIL2BAN = "true";
        XUI_LOG_LEVEL = "info";
      };

      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
      ];
    };
  };

  services.sing-box = {
    enable = true;
    settings = {
      log.level = "debug";
      dns = {
        servers = [
          {
            type = "https";
            tag = "dns-proxy";
            server = "1.1.1.1";
            server_port = 443;
            path = "/dns-query";
            detour = "socks-out";
          }
        ];
        final = "dns-proxy";
      };
      inbounds = [
        {
          type = "socks";
          tag = "socks-in";
          listen = "127.0.0.1";
          listen_port = 1080;
        }
        {
          type = "tun";
          tag = "tun-in";
          interface_name = "singbox-tun0";
          address = ["172.19.0.1/30"];
          auto_route = true;
          auto_redirect = true;
          strict_route = true;
          stack = "gvisor";
          #route_exclude_address = ["172.17.0.0/16"];
          route_address = ["0.0.0.0/0"];
          route_exclude_address = [];
          exclude_interface = ["docker0"];
        }
      ];
      outbounds = [
        {
          type = "socks";
          tag = "socks-out";
          server = "127.0.0.1";
          server_port = 10800;
          udp_over_tcp = true;
        }
        {
          type = "direct";
          tag = "direct";
        }
      ];
      route = {
        rules = [
          {
            action = "sniff";
            inbound = "tun-in";
          }
          {
            protocol = "dns";
            action = "hijack-dns";
          }
          # {
          #   inbound = ["tun-in"];
          #   ip_is_private = true;
          #   action = "route";
          #   outbound = "direct";
          # }
          # {
          #   ip_cidr = ["192.168.1.200/32"];
          #   outbound = "direct";
          # }
          {
            source_ip_cidr = ["172.17.0.0/16"];
            outbound = "direct";
          }
        ];
        final = "socks-out";
      };
    };
  };

  systemd.services.sing-box-lan-routing = {
    description = "Route LAN traffic from user applications through sing-box";
    wantedBy = ["multi-user.target"];
    after = ["sing-box.service"];
    requires = ["sing-box.service"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      IP=${pkgs.iproute2}/bin/ip
      USER_ID=${toString config.users.users.hypoxie.uid}

      while $IP -4 rule del priority 100 \
        uidrange "$USER_ID-$USER_ID" \
        to 192.168.1.0/24 \
        lookup 2022 2>/dev/null; do
        :
      done

      PRIORITY=100

      for CIDR in \
        10.0.0.0/8 \
        172.16.0.0/12 \
        192.168.0.0/16
      do
        while $IP -4 rule del priority "$PRIORITY" \
          uidrange "$USER_ID-$USER_ID" \
          to "$CIDR" \
          lookup 2022 2>/dev/null; do
          :
        done

        $IP -4 rule add priority "$PRIORITY" \
          uidrange "$USER_ID-$USER_ID" \
          to "$CIDR" \
          lookup 2022

        PRIORITY=$((PRIORITY + 1))
      done
    '';

    preStop = ''
      IP=${pkgs.iproute2}/bin/ip
      USER_ID=${toString config.users.users.hypoxie.uid}

      PRIORITY=100

      for CIDR in \
        10.0.0.0/8 \
        172.16.0.0/12 \
        192.168.0.0/16
      do
        while $IP -4 rule del priority "$PRIORITY" \
          uidrange "$USER_ID-$USER_ID" \
          to "$CIDR" \
          lookup 2022 2>/dev/null; do
          :
        done

        PRIORITY=$((PRIORITY + 1))
      done
    '';
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [
      virtiofsd
    ];
  };

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
  system.stateVersion = "26.05"; # Did you read the comment?
}
