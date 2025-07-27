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
      ssl.cert = "/var/lib/acme/balticumvirtus.com/fullchain.pem";
      ssl.key = "/var/lib/acme/balticumvirtus.com/key.pem";
      virtualHosts."balticumvirtus.com" = {
        enabled = true;
	domain = "balticumvirtus.com";
      };
      muc = [ {
        domain = "conference.balticumvirtus.com";
      } ];
      uploadHttp = {
        domain = "upload.balticumvirtus.com";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 5222 ];
  users.users.nginx.extraGroups = ["acme"];
  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/prosody"
    ];
  };
}
