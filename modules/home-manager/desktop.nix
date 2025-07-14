{pkgs, ...}: {
  imports = [
    ./_wayland.nix
    ./_hyprland.nix
  ];
  programs.firefox.enable = true;
  programs.vscode.enable = true;

}
