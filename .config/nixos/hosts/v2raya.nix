{
  config,
  lib,
  pkgs,
  ...
}: let
  version = "2.5.15";

  v2rayaBinary = pkgs.fetchurl {
    url = "https://github.com/v2rayA/v2rayA/releases/download/v${version}/v2raya_linux_x64_${version}";
    hash = "sha256-dVEWjn8tAl7K5aX/S6Im4Deq4gPG2SUvxm3245RzrOQ=";
  };

  v2rayaCore = pkgs.fetchurl {
    url = "https://github.com/v2rayA/v2rayA/releases/download/v${version}/v2raya_core_linux_x64_${version}";
    hash = "sha256-z5JYpA1qPk3zuA5Eg5N+M2NPIQkN3BhoAW59xtojE7I=";
  };

  v2raya = pkgs.stdenv.mkDerivation {
    pname = "v2raya";
    inherit version;

    dontUnpack = true;
    dontBuild = true;

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    buildInputs = [
      pkgs.stdenv.cc.cc.lib
    ];

    installPhase = ''
      install -Dm755 ${v2rayaBinary} "$out/bin/v2raya"
      install -Dm755 ${v2rayaCore} "$out/bin/v2raya_core"
    '';
  };

  v2rayaAssets = pkgs.runCommand "v2raya-assets" {} ''
    mkdir -p "$out"

    ln -s ${pkgs.v2ray-rules-dat}/share/v2ray/geoip.dat \
      "$out/geoip.dat"

    ln -s ${pkgs.v2ray-rules-dat}/share/v2ray/geosite.dat \
      "$out/geosite.dat"
  '';
in {
  boot.kernelModules = ["tun"];

  environment.systemPackages = [
    v2raya
  ];

  systemd.services.v2raya = {
    description = "v2rayA proxy service";

    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];

    path = [
      pkgs.bash
      pkgs.iproute2
      pkgs.nftables
    ];

    environment = {
      V2RAYA_V2RAY_ASSETSDIR = "${v2rayaAssets}";
      V2RAYA_LOG_FILE = "/var/log/v2raya/v2raya.log";
    };

    serviceConfig = {
      Type = "simple";
      User = "root";

      ExecStart = ''
        ${v2raya}/bin/v2raya \
          --config /var/lib/v2raya \
          --address 0.0.0.0:2017 \
          --log-disable-timestamp
      '';

      Restart = "on-failure";
      RestartSec = "5s";

      StateDirectory = "v2raya";
      StateDirectoryMode = "0700";

      LogsDirectory = "v2raya";
      LogsDirectoryMode = "0750";

      KillMode = "mixed";

      LimitNPROC = 500;
      LimitNOFILE = 1000000;
    };
  };
  systemd.services.v2raya-routing = {
    description = "Custom LAN routing through v2rayA TUN";

    wantedBy = ["multi-user.target"];
    after = ["v2raya.service"];
    requires = ["v2raya.service"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
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
          lookup 2020 2>/dev/null; do
          :
        done

        $IP -4 rule add priority "$PRIORITY" \
          uidrange "$USER_ID-$USER_ID" \
          to "$CIDR" \
          lookup 2020

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
          lookup 2020 2>/dev/null; do
          :
        done

        PRIORITY=$((PRIORITY + 1))
      done
    '';
  };
}
