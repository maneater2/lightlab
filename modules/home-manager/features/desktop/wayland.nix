{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.wayland;
in {
  options.features.desktop.wayland.enable = mkEnableOption "wayland extra tools and config";

  config = mkIf cfg.enable {
    programs = {
      waybar = {
        enable = true;
        # TODO add theming
        };

      kitty = {
        enable = true;
      };
    };

    home.packages = with pkgs; [
      hyprpaper
      grim
      hyprlock
      qt6.qtwayland
      slurp
      wl-clipboard
      
      # fonts
      noto-fonts
      noto-fonts-emoji

      nerdfonts.override {fonts = ["JetBrainsMono"];}
    ];
  };
}
