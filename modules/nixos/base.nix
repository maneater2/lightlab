# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  vars,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops

    ./_packages.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.canTouchEfiVariables = true;
    timeout = 10;
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets."user-password".neededForUsers = true;
    secrets."user-password" = {};
    gnupg.sshKeyPaths = [];
  };

  users.mutableUsers = false;
  users.users.${vars.userName} = {
    isNormalUser = true;
    description = vars.userName;
    extraGroups = ["networkmanager" "wheel"];
    openssh.authorizedKeys.keys = [
      vars.sshPublicKeyPersonal
    ];
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets."user-password".path;
  };

  services = {
    fstrim.enable = true;
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      openFirewall = true;
    };
  };

  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
    nameservers = ["1.1.1.1" "9.9.9.9"];
  };

  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
    };
  };

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  time.timeZone = "Europe/Vilnius";
  zramSwap.enable = true;

  environment.persistence."/nix/persist" = {
    # Hide these mounts from the sidebar of file managers
    hideMounts = true;

    directories = [
      "/var/log"
      # inspo: https://github.com/nix-community/impermanence/issues/178
      "/var/lib/nixos"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
