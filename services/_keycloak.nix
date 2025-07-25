{
  config,
  pkgs,
  lib,
  ...
}: {

  imports = [
    ./_acme.nix
    ./_nginx.nix
  ];

  sops.secrets."keycloak-pass" = {};


  services.keycloak = {
    enable = true;
    initialAdminPassword = "mamaimacriminal123";
#    themes = with pkgs; [
#      custom = custom_keycloak_themes.custom;
#    ];
    database = {
      type = "postgresql";
      createLocally = true;

      username = "keycloak";
      passwordFile = config.sops.secrets."keycloak-pass".path;
    };
    settings = {
      spi-theme-static-max-age = "-1";
      spi-theme-cache-themes = false;
      spi-theme-cache-templates = false;
      http-port = 8821;
      hostname = "cloak.balticumvirtus.com";
      hostname-strict = false;
      hostname-strict-https = false;
      proxy-headers = "xforwarded";
      http-enabled = true;
      frontend-url = "https://cloak.balticumvirtus.com";
    };
  };

  services.nginx.virtualHosts."cloak.balticumvirtus.com" = {
    forceSSL = true;
    useACMEHost = "balticumvirtus.com";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8821";
      extraConfig = ''
        proxy_set_header X-Forwarded-Proto https;
	proxy_set_header X-Forwarded-Host $host;
      '';
    };
  };

 # environment.persistence."/nix/persist" = {
 # actually this directory is not needed because keycloak uses postgresql anyway!
 #   directories = [ "/var/lib/keycloak" ]; # also add a directory for postgresql if nextcloud.nix is not used, can't have it on both files at the same time
 # };

  environment.systemPackages = with pkgs; [
    keycloak
    #custom_keycloak_themes.verydeliciouspie # TODO
  ];

  services.postgresql.enable = true;
}
