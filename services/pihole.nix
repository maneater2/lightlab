{
  pkgs,
  ...
}:
{
  imports = [
    ./_acme.nix
    ./_nginx.nix
    ./_cloudflared.nix
  ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
	dates = "weekly";
	flags = [
          "--filer=until=24h"
	  "--filter=label!=important"
	];
      };
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  virtualisation.oci-containers.containers."pihole" = {
    image = "pihole/pihole";
    autoStart = true;
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "3080:80/tcp"
      "30443:443/tcp"
    ];
    environment = {
      TZ = "Europe/Vilnius";
      FTLCONFG_webserver_api_password = "changeme";
      FTLCONF_dns_listeningMode = "all";
    };
    volumes = [
      "/var/lib/pihole:/etc/pihole"
      "/var/lib/dnsmasq.d:/etc/dnsmasq.d"
    ];
    extraOptions = [
      "--cap-add=NET_ADMIN"
    ];
  };

  networking.firewall.allowedUDPPorts = [53];
  networking.firewall.allowedTCPPorts = [53];

  services.nginx = {
    virtualHosts = {
      "pihole.balticumvirtus.com" = {
        forceSSL = true;
	useACMEHost = "balticumvirtus.com";
	locations."/" = {
          recommendedProxySettings = true;
	  proxyPass = "http://127.0.0.1:30443";
	};
      };
    };
  };

  systemd = {
    tmpfiles.rules = [
      "d /var/lib/pihole 0755 root root"
      "d /var/lib/dnsmasq.d 0755 root root"
    ];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/pihole"
      "/var/lib/dnsmasq.d"
    ];
  };

}
