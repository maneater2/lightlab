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

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # enables Docker CLI via Podman
    defaultNetwork.settings.dns_enabled = true;  # enables DNS in containers
  };

  environment.persistence."/nix/persist".directories = [
    "/var/lib/containers"
    "/var/lib/pihole"
    "/var/lib/dnsmasq"
  ];

  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    podman-compose
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/pihole 0755 root root"
    "d /var/lib/dnsmasq 0755 root root"
  ];

  users.users.${vars.userName}.extraGroups = ["podman"];

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports = [
      "10.0.0.2:53:53/udp"
      "10.0.0.2:53:53/tcp"
      "3080:80/tcp"
      "30443:443/tcp"
    ];
    environment = {
      ServerIP = "10.0.0.2";
    };
    volumes = [
      "/var/lib/pihole/:/etc/pihole/"
      "/var/lib/dnsmasq.d:/etc/dnsmasq.d/"
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
