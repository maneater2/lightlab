{
  pkgs,
  ...
}:
with lib; let
  cfg = options.features.desktop.stylix;
in
{
  options.features.desktop.stylix.enable = mkEnableOption "stylix colors";

  config = mkIf cfg.enable {
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml"
    stylix.cursor.package = pkgs.bibata-cursors;
    stylix.cursor.name = "Bibata-Modern-Ice";
    stylix.polarity = "dark";

    stylix.fonts = {
      monospace = {
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
	name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
	name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
	name = "DejaVu Serif";
      };
    };
  };
}
