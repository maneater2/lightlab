{
  pkgs,
  lib,
  ...
}: {
  hardware = {
    graphics = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linx.amdvlk
      ];
    };
  };

  programs = {
    gamemode.enable = true;
    gamescope.enable = true;
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      extraPackages = with pkgs; [
        SDL2
        gamescope
        er-patcher
      ];
      protontricks.enable = true;
    };
  };
}
