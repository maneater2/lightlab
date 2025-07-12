{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      env = [
        # Hint electron apps to use wayland
	"NIXOS_OZONE_WL,1"
	"XDG_CURRENT_DESKTOP,Hyprland"
	"XDG_SESSION_TYPE,wayland"
	"XDG_SESSION_DESKTOP,Hyprland"
	"QT_QPA_PLATFORM,wayland"
	"XDG_SCREENSHOTS_DIR,$HOME/Pictures/Screenshots"
      ];

      monitor = ",1920x1080@144,auto,1";
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
    };
  };
}
