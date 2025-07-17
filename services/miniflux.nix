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
    };
  };

  services = {
    miniflux = {
      enable = true;
      adminCredentialsFile = config.sops.secrets."miniflux-cred".path;
      config = {
        BASE_URL = "https://miniflux.balticumvirtus.com";
        LISTEN_ADDR = "127.0.0.1:9013";
      };
    };

    nginx = {
      virtualHosts = {
        "miniflux.balticumvirtus.com" = {
          forceSSL = true;
          useACMEHost = "balticumvirtus.com";
          locations."/" = {
            proxyPass = "http://127.0.0.1:9013";
	    extraConfig = ''
              auth_oidc_client_id "miniflux";
              auth_oidc_client_secret "pd6t94126Iux3B8GvqlwIGZeK3PeuQZj";
              auth_oidc_discovery "https://cloak.balticumvirtus.com/auth/realms/master/.well-known/openid-configuration";
              auth_oidc_scope "openid email profile";
              auth_oidc_redirect_uri "https://miniflux.balticumvirtus.com/*";

              auth_oidc_logout_path /logout;
              auth_oidc_pass_authorization_header on;

              auth_oidc_session_cookie keycloak-session;
              auth_oidc_session_timeout 1h;
            '';
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
