{
  pkgs,
  vars,
  ...
}: {

  imports = [
    ./home-manager/firefox.nix
    ./home-manager/hyprland/default.nix
  ];

  home.packages = with pkgs; [
    code-cursor
    imv
    mpv
    obs-studio
    pavucontrol
    vesktop
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
