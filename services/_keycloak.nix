{
  config,
  pkgs,
  lib,
  ...
}: let
  fqdn = "keycloak.balticumvirtus.com";
in
{

  imports = [
    ./_acme.nix
    ./_nginx.nix
  ];

  sops.secrets."keycloak-pass" = {};

  services.keycloak = {
    enable = true;
    initialAdminPassword = config.sops.secrets."keycloak-pass".path;
    settings = {
      spi-theme-static-max-age = "-1";
      spi-theme-cache-themes = false;
      spi-theme-cache-templates = false;
      http-port = 8821;
      hostname = fqdn;
      hostname-strict = false;
      hostname-strict-https = false;
      proxy-headers = "xforwarded";
      http-enabled = true;
    };
  };

  services.nginx.virtualHosts."${fqdn}" = {
    forceSSL = true;
    useACMEHost = "balticumvirtus.com";

    locations."/" = {
      proxyPass = "http://127.0.0.1:8821";
      proxyWebsockets = true;
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [ "/var/lib/keycloak" ]; # also add a directory for postgresql if nextcloud.nix is not used, can't have it on both files at the same time
  };
}
