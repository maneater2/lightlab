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

    ./../../modules/nixos/desktop.nix
    ./../../modules/nixos/base.nix
    ./../../modules/nixos/power-management.nix # for laptops
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
	  ./../../modules/home-manager/desktop.nix
        ];
      };
    };
  };

  networking.hostName = "muffin";
}
