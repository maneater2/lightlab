{
  description = "lightlab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    vars = import ./vars.nix;

    systems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkNixOSConfig = path:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs vars;};
	modules = [path];
      };
  in {
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      carrotcake = mkNixOSConfig ./machines/carrotcake/configuration.nix;
    };
  };
}
