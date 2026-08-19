{
  description = "NixOS on VM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.vm =
        let
          system = "aarch64-linux";
          pkgsUnstable = import inputs.nixpkgs-unstable { inherit system; };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs pkgsUnstable;
          };

          modules = [
            ./configuration.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.extraSpecialArgs = {
                inherit inputs pkgsUnstable;
              };

              home-manager.users.alex = import ./home.nix;
            }
          ];
        };
    };
}
