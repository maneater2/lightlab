{
  inputs,
  outputs,
  vars,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence

    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix

    ./../../modules/home-manager/features/cli
    ./../../modules/home-manager/features/desktop
  ];

  features = {
    cli = {
      fish.enable = true;
      fzf.enable = true;
    };
    desktop = {
      wayland.enable = true;
      hyprland.enable = true;
      stylix.enable = true;
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs vars;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      ${vars.userName} = {
        imports = [
          ./../../modules/home-manager/base.nix
        ];
      };
    };
  };

  networking.hostName = "cupcake";
}
