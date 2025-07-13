{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./_binds.nix
    ./_hypridle.nix
    ./_hyprlock.nix
    ./_hyprpaper.nix
    ./../_wofi/default.nix
  ];

  programs.uwsm.enable = true;

  home.packages = with pkgs; [
    libsForQt5.xwaylandvideobridge
    libnotify
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    bemoji
    wl-clipboard
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = lib.mkForce "rgba(${config.stylix.base16Scheme.base0E}ff) rgba(${config.stylix.base16Scheme.base09}ff) 60deg";
        "col.inactive.border" = lib.mkForce "rgba(${config.stylix.base16Scheme.base00}ff)";
        layout = "dwindle";
        allow_tearing = true;
        resize_on_border = true;
      };
      monitor = ",1920x1080@144,auto,1";

      env = [
        # Hint electron apps to use wayland
        "NIXOS_OZONE_WL,1"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_QPA_PLATFORM,wayland"
        "XDG_SCREENSHOTS_DIR,$HOME/Pictures/Screenshots"
      ];

      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "$terminal -e sh -c 'ranger'";
      "$menu" = "wofi";

      exec-once = [
        "waybar"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      input = {
        kb_layout = "us,lt";
        kb_variant = "";
        kb_options = "grp:alt_shift_toggle,caps:escape";
        kb_rules = "";
        follow_mouse = 1;
        touchpad.natural_scroll = false;
        repeat_rate = 40;
        repeat_delay = 250;
        force_no_accel = true;
        sensitivity = 0.0;
      };

      misc = {
        enable_swallow = true;
        force_default_wallpaper = 0;
      };

      binds = {
        movefocus_cycles_fullscreen = 0;
      };

      debug = {
        suppress_errors = true;
      };

      animations = {
        enable = true;
        bezier = "myBezier, 0.25, 0.9, 0.1, 1.02";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_invert = false;
        workspace_swipe_forever = true;
      };
    };

    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard

      networkmanagerapplet
    ];
  };
}
