{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.nixosModules.stylix
    ./wayland.nix
    ./stylix.nix
    ./hyprland.nix
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];

    users.${vars.userName} = {
      directories = [
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"

        ".cache"
        ".config"
        ".mozilla"
        ".local"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
    };
  };
}
