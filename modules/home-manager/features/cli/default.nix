{
  pkgs,
  ...
}: {
  imports = [
    ./fish.nix
    ./fzf.nix
    ./git.nix
  ];

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    extraOptions = ["-l" "--icons" "--git" "-a"];
  };

  home.packages = with pkgs; [
    coreutils
    fd
    htop
    procs
    ripgrep
    tldr
    zip
  ];
}
