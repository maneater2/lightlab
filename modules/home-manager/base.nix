# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  lib,
  osConfig,
  pkgs,
  vars,
  ...
}: {
  imports = [
    ./_packages.nix
    ./_zsh.nix
    ./_gtk.nix
    ./_neovim.nix
  ];

  home = {
    username = vars.userName;
    homeDirectory = "/home/${vars.userName}";
    stateVersion = "25.05";
    sessionVariables = {
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    };
  };

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
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
