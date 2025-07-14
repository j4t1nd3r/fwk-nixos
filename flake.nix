# ./flake.nix

{
  description = "nixos flake config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/master";
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
    home-manager, 
    plasma-manager, 
    nix-vscode-extensions, 
    ... 
  }@inputs:

  let
    system = "x86_64-linux";
    sddmOverlay = (final: prev: { sddm = prev.sddm-qt6; });
  in {

    nixosConfigurations = {
      fwk-nixos = nixpkgs.lib.nixosSystem {
        system  = "x86_64-linux";
        specialArgs = { inherit inputs system; };
        
        modules = [
          ./nixos/configuration.nix
          nixos-hardware.nixosModules.framework-16-7040-amd
          home-manager.nixosModules.default
          ({ ... }: { nixpkgs.overlays = [ sddmOverlay ]; })
        ];
      };
    };
  };
}