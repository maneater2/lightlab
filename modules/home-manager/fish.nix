{
  config,
  lib,
  pkgs,
  ...
}:
{

    programs.fish = {
      enable = true;
      loginSHellInit = ''
      set -x NIX_PATH nixpkgs=channel:nixos-unstable
      set -x NIX_LOG info
      set -x TERMINAL kitty

      if test (tty) = "/dev/tty1"
        exec Hyprland &> /dev/null
      end
      '';
      shellAbbrs = {
        ".." = "cd ..";
	"..." = "cd ../..";
	ls = "eza";
	grep = "rg";
	ps = "procs";
      };
    };
}
