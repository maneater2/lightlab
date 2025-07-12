{
  config,
  pkgs,
  vars,
  ...
}: {

  sops.secrets."miniflux-cred" = {};

  imports = [
    ./_acme.nix
    ./_nginx.nix
    ./_cloudflared.nix
  ];

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
}
