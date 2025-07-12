{
  config,
  pkgs,
  vars,
  ...
}: {
  imports = [
    ./_acme.nix
    ./_cloudflared.nix
    ./_nginx.nix
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
}
