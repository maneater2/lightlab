{vars, ...}: {
  imports = [
    ./_packages.nix
  ];

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      vars.sshPublicKeyPersonal
    ];
  };

  programs.bash.shellAliases = {
    install = "sudo bash -c '$(curl -fsSL https://raw.githubusercontent.com/maneater2/lightlab/main/install.sh)'";
  };

  security.sudo.wheelNeedsPassword = false;

  # needed for ventoy
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.openssh = {
    enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
