{
  description = "nixos flake config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { 
    self,
    nixpkgs,
    nixos-hardware,
    plasma-manager,
    nix-vscode-extensions, 
    ... 
  }@inputs:

  let
    system = "x86-64-linux";

    pkgs = import nixpkgs {
      inherit system; 
      config.allowUnfree = true;
    };

    extensions = inputs.nix-vscode-extensions.extensions.${system};

    in

    {
    nixosConfigurations = {
      fwk-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system; };

        modules = [
        ./nixos/configuration.nix
        nixos-hardware.nixosModules.framework-16-7040-amd
        inputs.home-manager.nixosModules.default {
            home-manager.extraSpecialArgs = { inherit nix-vscode-extensions; };
          }
        ];
      };
    };
  };
}