{
  pkgs,
  vars,
  ...
}: {

  imports = [
    ./_sddm/default.nix
    ./_power-management.nix
    ./../home-manager/_firefox.nix
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
        "OneDrive"
        "Pictures"
        "Videos"
        "git"

        ".cache"
        ".config"
        ".mozilla"
        ".vscode"
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
      files = [
        ".zsh_history"
      ];
    };
  };
}
