{
  imports = [
    ./_nginx.nix
    ./_cloudflared.nix
    ./_acme.nix
  ];

  services = {
    prosody = {
      enable = true;
      admins = [ "pielover@balticumvirtus.com" ];
      virtualHosts."balticumvirtus.com" = {
        enabled = true;
	domain = "balticumvirtus.com";
        ssl.cert = "/var/lib/acme/balticumvirtus.com/fullchain.pem";
        ssl.key = "/var/lib/acme/balticumvirtus.com/key.pem";
      };
      muc = [ {
        domain = "conference.balticumvirtus.com";
      } ];
      uploadHttp = {
        domain = "upload.balticumvirtus.com";
      };
    };
  };
  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/prosody"
    ];
  };
  systemd.tmpfiles.rules = [
    "d /etc/prosody 0755 prosody prosody -"
    "R /etc/prosody 0755 prosody prosody -"
  ];
  networking.firewall.allowedTCPPorts = [ 5222 ];
}
