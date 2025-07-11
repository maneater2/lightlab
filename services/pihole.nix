{
  config,
  pkgs,
  vars,
  ...
}:
{

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
    podman
    podman-compose
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/pihole 0755 root root"
    "d /var/lib/dnsmasq 0755 root root"
  ];

  users.users.${vars.userName}.extraGroups = ["podman"];

  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports = [
      "53:53/udp"
      "53:53/tcp"
      "10542:80/tcp"
    ];
    environment = {
      TZ = "Europe/Vilnius";
      WEBPASSWORD = "changeme";  # optionally use SOPS here
    };
    volumes = [
      "/var/lib/pihole:/etc/pihole"
      "/var/lib/dnsmasq:/etc/dnsmasq.d"
    ];
    extraOptions = [ "--cap-add=NET_ADMIN" ];
  };

  nginx = {
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
