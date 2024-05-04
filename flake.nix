{
  description = "nixos flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs }:
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
        specialArgs = { inherit system; };

        modules = [
        ./nixos/configuration.nix
        ];
      };
    };
  };
}