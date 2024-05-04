{
  description = "nixos flake config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, plasma-manager, ... }@inputs:
  let
    system = "x86-64-linux";

    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
      };
    };

    in
    {
    nixosConfigurations = {
      fwk-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };

        modules = [
        ./nixos/configuration.nix
        inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}