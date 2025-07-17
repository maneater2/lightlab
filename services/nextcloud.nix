{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./_cloudflared.nix
    ./_keycloak.nix
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
}
