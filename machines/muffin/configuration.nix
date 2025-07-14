{
  inputs,
  outputs,
  vars,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    inputs.stylix.nixosModules.stylix

    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../modules/nixos/power-management.nix
    ./../../modules/nixos/stylix.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs vars;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      ${vars.userName} = {
        imports = [
          ./../../modules/home-manager/base.nix
          ./../../modules/home-manager/git.nix
 #         ./../../modules/home-manager/hyprland.nix
          ./../../modules/home-manager/wayland.nix
        ];
      };
    };
  };

  networking.hostName = "muffin";
}
