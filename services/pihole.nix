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

  services.piHole = {
    enable = true;
    interface = "eno1";
    dnsIp = "127.0.0.1";
    ipAddress = "0.0.0.0"; # Default to listen on all interfaces
    blockingMode = "IP";   # IP or DNS-based blocking
    webInterface = true;   # Enable the Pi-hole web interface
    webPassword = "changeme"; # TODO use sops
  };

  services.nginx = {
    virtualHosts = {
      "pihole.balticumvirtus.com" = {
        forceSSL = true;
	useACMEHost = "balticumvirtus.com";
	locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
	  recommendedProxySettings = true;
	};
      };
    };
  };

  networking.firewall.allowedTCPPorts = [53];

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/pihole"
      "/var/lib/pihole"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/pihole 0755 root root"
    "d /etc/pihole 0755 root root"
  ];
}
