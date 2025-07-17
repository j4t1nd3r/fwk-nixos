{
  description = "Framework-16 system + HM profile";

  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url   = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows      = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = inputs@{ 
    self, 
    nixpkgs, 
    nixos-hardware, 
    home-manager, 
    plasma-manager, 
    nix-vscode-extensions, 
    ... 
  }:

    let
    system = "x86_64-linux";

    sddmOverlay = final: prev: { sddm = prev.sddm-qt6; };

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        sddmOverlay
        inputs."nix-vscode-extensions".overlays.default
      ];
    };
  in
  {
    nixosConfigurations."fwk-nixos" =
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs system; };
        modules = [
          ./nixos/configuration.nix
          nixos-hardware.nixosModules.framework-16-7040-amd
          home-manager.nixosModules.default
          ({ ... }: { nixpkgs.overlays = [ sddmOverlay ]; })
        ];
      };

    homeConfigurations."jat" =
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix ];
      };
  };
}