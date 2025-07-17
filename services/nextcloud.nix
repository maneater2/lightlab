{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./_acme.nix
    ./_nginx.nix
    ./_cloudflared.nix
  ];

  sops.secrets.nextcloud-adminpassfile = {
    owner = "nextcloud";
    group = "nextcloud";
  };

  services = {
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud31;
      hostName = "cloud.balticumvirtus.com";

      https = true;
      maxUploadSize = "16G";
      configureRedis = true;
      database.createLocally = true;
      # As recommended by admin panel
      phpOptions."opcache.interned_strings_buffer" = "24";

      extraAppsEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps) previewgenerator;
      };

      config = {
        adminuser = "admin";
        adminpassFile = config.sops.secrets.nextcloud-adminpassfile.path;
        dbtype = "pgsql";
      };

      settings = {
        defaultPhoneRegion = "LT";
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          # Not included by default
          "OC\\Preview\\HEIC"
          "OC\\Preview\\Movie"
          "OC\\Preview\\MP4"
        ];
      };
    };

    nginx = {
      virtualHosts = {
        "${config.services.nextcloud.hostName}" = {
          forceSSL = true;
          useACMEHost = "balticumvirtus.com";
        };
      };
    };
  };

  # Need ffmpeg to handle video thumbnails
  environment.systemPackages = with pkgs; [
    ffmpeg
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nextcloud"
      "/var/lib/postgresql"
    ];
  };

  systemd.services = {
    "cloudflared-route-tunnel-nextcloud" = {
      description = "Point traffic to tunnel subdomain";
      after = [
        "network-online.target"
        "cloudflared-tunnel-lightlab-01.service"
      ];
      wants = [
        "network-online.target"
        "cloudflared-tunnel-lightlab-01.service"
      ];
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "oneshot";
        # workaround to ensure dns is available before setting up cloudflare tunnel
        # inspo: chatgpt
        ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in {1..10}; do ${pkgs.iputils}/bin/ping -c1 api.cloudflare.com && exit 0 || sleep 3; done; exit 1'";
        ExecStart = {
         "${lib.getExe pkgs.cloudflared} tunnel route dns 'lightlab-01' 'cloud.balticumvirtus.com'"
        };
      };
    };
  };
}
