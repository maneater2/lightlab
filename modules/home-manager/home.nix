# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./_packages.nix
    ./_zsh.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # TODO: Set your username
  home = {
    username = vars.userName;
    homeDirectory = "/home/${vars.userName}";
    stateVersion = "25.05";
  };

  programs = {
    helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "dark_high_contrast";
      };
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    zellij = {
      enable = true;
      settings = {
        theme = "dracula";
      };
    };
    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    bat.enable = true;
    btop.enable = true;
    gallery-dl.enable = true;
    fastfetch.enable = true;
    htop.enable = true;
    lsd.enable = true;
    nh.enable = true;
    vim.enable = true;
    yt-dlp.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
