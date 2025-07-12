{ vars, ... }: {
  programs.nh = {
    enable = true;
    flake = "/home/${vars.userName}/flake";
  };
}
