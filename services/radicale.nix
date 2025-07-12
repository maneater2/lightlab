{
  config,
  pkgs,
  vars,
  ...
}: {
  imports = [
    ./_acme.nix
    ./_nginx.nix
    ./_cloudflared.nix
  ];

  sops.secrets."radicale-htpasswd" = {
    owner = "radicale";
    group = "radicale";
  };

  services = {
    radicale = {
      enable = true;
      settings = {
        server = {
          hosts = [ "127.0.0.1:5232" ];
        };
        auth = {
          type = "htpasswd";
	  htpasswd_filename = config.sops.secrets."radicale-htpasswd".path;
  	  htpasswd_encryption = "bcrypt";
        };
      };
    };
    
    nginx = {
      virtualHosts = {
        "dav.balticumvirtus.com" = {
          forceSSL = true;
	  useACMEHost = "balticumvirtus.com";
	  locations."/" = {
            proxyPass = "http://127.0.0.1:5232/";
	    recommendedProxySettings = true;
	  };
	  extraConfig = ''
            proxy_set_header X-Forwarder-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
	  '';
	};
      };
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/radicale"
    ];
  };
}
