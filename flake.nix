# repo:     https://github.com/j4t1nd3r/fwk-nixos
# filepath: ./flake.nix

{
  description = "fmwk 16 flake w/ home-manager";

  inputs = {
    nixpkgs.url         = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url  = "github:NixOS/nixos-hardware"; # no nixpkgs input to follow — modules consume nixpkgs via the host system

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows      = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ 
    self, 
    nixpkgs, 
    nixos-hardware, 
    home-manager,
    plasma-manager,
    nix-vscode-extensions,
    agenix,
    ... 
  }:

    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.nix-vscode-extensions.overlays.default
        ];
      };
    in
    {
    nixosConfigurations."fwk-nixos" =
      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./nixos/configuration.nix
          nixos-hardware.nixosModules.framework-16-7040-amd
          ({ ... }: { nixpkgs.pkgs = pkgs; nixpkgs.hostPlatform = system; })
          agenix.nixosModules.default
        ];
      };
    };
}