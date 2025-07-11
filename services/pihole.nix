{
  config,
  pkgs,
  vars,
  ...
}:
{

  imports = [
    ./_acme.nix
    ./_nginx.nix
    ./_cloudflared.nix
  ];

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  virtualisation.docker.enable = true;

  environment.persistence."/nix/persist".directories = [
    "/var/lib/containers"
    "/var/lib/pihole"
    "/var/lib/dnsmasq.d"
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/pihole 0755 root root"
    "d /var/lib/dnsmasq.d 0755 root root"
  ];

  virtualisation.docker.containers.pihole = {
    image = "pihole/pihole:latest";
    autoStart = true;
    ports = [
      "53:53/udp"
      "53:53/tcp"
      "3080:80/tcp"
      "30443:443/tcp"
    ];
    environment = {
      TZ = "Europe/Vilnius";
      WEBPASSWORD = "changeme";
    };
    volumes = [
      "/var/lib/pihole:/etc/pihole"
      "/var/lib/dnsmasq.d:/etc/dnsmasq.d"
    ];
    extraOptions = [
    "--cap-add=NET_ADMIN"
    "--dns=127.0.0.1"
    "--dns=1.1.1.1"
    ];
    workdir = "/var/lib/pihole/";
  };

  services.nginx = {
    virtualHosts = {
      "pihole.balticumvirtus.com" = {
        forceSSL = true;
        useACMEHost = "balticumvirtus.com";
	locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:10542";
        };
      };
    };
  };
}
