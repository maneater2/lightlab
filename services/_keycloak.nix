{ config, vars, ... }: {
  imports = [
    ./_nginx.nix
  ];

  sops.secrets.keycloak-pass = {
    owner = "keycloak";
    group = "keycloak";
  };

  services = {
    keycloak = {
      enable = true;
      database.type = "postgresql";
      initialAdminUser = "${vars.userName}";
      initialAdminPasswordFile = config.sops.secrets.keycloak-pass.path;
    };

    nginx = {
      virtualHosts = {
        "auth.balticumvirtus.com" = {
          forceSSL = true;
	  useACMEHost = "balticumvirtus.com";
	  locations."/" = {
            proxyPass = "http://localhost:8080";
	    proxyWebsockets = true;
	  };
	};
      };
    };
  };
}
