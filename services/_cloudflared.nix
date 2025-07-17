{
  config,
  pkgs,
  lib,
  ...
}: {
  sops.secrets = {
    "cloudflare-tunnel" = {
      format = "binary";
      sopsFile = ./../secrets/cloudflare-tunnel;
    };
    "cloudflare-token" = {
      format = "binary";
      sopsFile = ./../secrets/cloudflare-cert.pem;
    };
  };

  environment.etc."cloudflared/cert.pem".source = config.sops.secrets."cloudflare-token".path;

  services.cloudflared = {
    enable = true;
    tunnels = {
      "lightlab-01" = {
        credentialsFile = config.sops.secrets."cloudflare-tunnel".path;
        default = "http_status:404";
        ingress = {
          "watch.balticumvirtus.com" = {
            service = "http://localhost:8096";
          };
	  "miniflux.balticumvirtus.com" = {
            service = "http://localhost:9013";
	  };
	  "cloud.balticumvirtus.com" = {
            service = "http://localhost:80";
	  };
        };
      };
    };
  };

}
