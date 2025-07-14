{
  config,
  pkgs,
  ...
}:
{
    programs = {
      waybar = {
        enable = true;
        # TODO add theming
        };

      kitty = {
        enable = true;
      };
    };

  qt.platformTheme = "gtk";

    home.packages = with pkgs; [
      keepassxc
      hyprpaper
      grim
      hyprlock
      qt6.qtwayland
      slurp
      wl-clipboard
      
      # fonts
      noto-fonts
      noto-fonts-emoji

      nerd-fonts.jetbrains-mono
    ];
}
