{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      
      nerd-fonts.jetbrains-mono
    ];
  };
}
