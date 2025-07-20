{
  config,
  pkgs,
  vars,
  lib,
  ...
}: {
  imports = [
    ./_nginx.nix
    ./_keycloak.nix
  ];

  sops = {
    secrets = {
      "miniflux-cred" = {
        format = "binary";
        sopsFile = ./../secrets/miniflux-cred;
      };
      "miniflux-client-secret" = {};
    };
  };

  services = {
    miniflux = {
      enable = true;
      adminCredentialsFile = config.sops.secrets."miniflux-cred".path;
      config = {
        BASE_URL = "https://miniflux.balticumvirtus.com";
	CREATE_ADMIN = "1";
        LISTEN_ADDR = "127.0.0.1:9013";
	OAUTH2_PROVIDER = "oidc";
	OAUTH2_CLIENT_ID = "miniflux";
	OAUTH2_CLIENT_SECRET = config.sops.secrets."miniflux-client-secret".path;
	OAUTH2_REDIRECT_URL = "https://miniflux.balticumvirtus.com/oauth2/oidc/callback";
	OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://cloak.balticumvirtus.com/realms/master";
	OAUTH2_USER_CREATION = "1";
	#DISABLE_LOCAL_AUTH = "1";
      };
    };

    nginx = {
      virtualHosts = {
        "miniflux.balticumvirtus.com" = {
          forceSSL = true;
          useACMEHost = "balticumvirtus.com";
          locations."/" = {
            proxyPass = "http://127.0.0.1:9013";
          };
        };
      };
    };
  };
  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/miniflux"
    ];
  };

  systemd.services = {
    "cloudflared-route-tunnel-miniflux" = {
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
        ExecStart = "${lib.getExe pkgs.cloudflared} tunnel route dns 'lightlab-01' 'miniflux.balticumvirtus.com'";
      };
    };
  };
}
