{
  description = "NixOS on VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./hosts/vm

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";

            home-manager.extraSpecialArgs = {
              inherit inputs;
            };

            home-manager.users.alex = import ./home/alex;
          }
        ];
      };
    };
}
