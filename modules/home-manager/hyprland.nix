{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{

    programs.waybar.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        general = {
	  gaps_in = 5;
	  gaps_out = 10;
          "col.active_border" = lib.mkForce "rgba(${config.stylix.base16Scheme.base0E}ff) rgba(${config.stylix.base16Scheme.base09}ff) 60deg";
	  "col.inactive_border" = lib.mkForce "rgba(${config.stylix.base16Scheme.base00}ff)";

	  layout = "dwindle";
	};

        monitor = [
          "DP-1,1920x1080@144,0x0,1"
	  "DP-2,1920x1080@144,1920x0,1"
	];

	exec-once = [
          "waybar"
	  "hyprpaper"
	  "hypridle"
	  "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
	];

        input = {
          kb_layout = "us,lt";
          kb_variant = "";
	  kb_model = "";
	  kb_options = "grp_alt_shift_toggle,caps:escape";

	  kb_rules = "";

	  follow_mouse = 1;

	  touchpad = {
            natural_scroll = false;
	  };

	  repeat_rate = 40;
	  repeat_delay = 250;
	  force_no_accel = true;

	  sensitivity = 0.0;
	};

	misc = {
          enable_swallow = true;
	  force_default_wallpaper = 0;
	};

	debug = {
          supress_errors = true;
	};

        animation = [
	  "windows, 1, 7, myBezier"
	  "windowsOut, 1, 7, default, popin 80%"
	  "border, 1, 10, default"
	  "borderangle, 1, 8, default"
	  "fade, 1, 7, default"
          "workspaces, 1, 3, myBezier, slide"
	];

        dwindle = {
          pseudotile = true;
	  preserve_split = true;
	  force_split = 2;
	};

	bind = [
          "$mainMod, return, exec, kitty"
          "$mainMod, Q, killactive,"
          "$mainMod SHIFT, F, togglefloating,"
          "$mainMod, F, fullscreen,"
          "$mainMod, T, pin,"
          "$mainMod, G, togglegroup,"
          "$mainMod, bracketleft, changegroupactive, b"
          "$mainMod, bracketright, changegroupactive, f"
          "$mainMod, S, exec, rofi -show drun -show-icons"
          "$mainMod, P, pin, active"

          ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"

          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, j, movewindow, d"
        ];

        binde = [
          "$mainMod SHIFT, h, moveactive, -20 0"
          "$mainMod SHIFT, l, moveactive, 20 0"
          "$mainMod SHIFT, k, moveactive, 0 -20"
          "$mainMod SHIFT, j, moveactive, 0 20"

          "$mainMod CTRL, l, resizeactive, 30 0"
          "$mainMod CTRL, h, resizeactive, -30 0"
          "$mainMod CTRL, k, resizeactive, 0 -10"
          "$mainMod CTRL, j, resizeactive, 0 10"
        ];

        bindm = [
          # Move/resize windows with mainMod + LMB/RMB and dragging
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
}
