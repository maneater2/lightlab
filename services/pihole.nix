{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./_acme.nix
    ./_nginx.nix
    ./_cloudflared.nix
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.containers = [
    {
      name = "pihole";
      image = "pihole/pihole:latest";
      extraOptions = "--restart=unless-stopped";
      ports = [
        "53:53/udp"
	"53:53/tcp"
	"3080:80/tcp"
	"30443:443/tcp"
      ];
      environment = {
        "ServerIP" = "127.0.0.1";
	"WEBPASSWORD" = "changeme";
	"DNS1" = "1.1.1.1";
	"DNS2" = "8.8.8.8";
	"VIRUTAL_HOST" = "pihole.balticumvirtus.com";
      };
      volumes = [
        "/var/lib/pihole:/etc/pihole"
	"/var/lib/dnsmasq.d:/etc/dnsmasq.d"
      ];
    }
  ];

  networking.firewall.allowedUDPPorts = ["53"];
  networking.firewall.allowedTCPPorts = ["53"];

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
