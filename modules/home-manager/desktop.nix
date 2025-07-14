{pkgs, ...}: {
  imports = [
    ./_wayland.nix
    ./_hyprland.nix
    ./_stylix.nix
  ];
  programs.firefox.enable = true;
  programs.vscode.enable = true;
  programs.keepassxc.enable = true;

}
