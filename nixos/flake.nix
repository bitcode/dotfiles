{
  description = "NixOS configuration with flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = system;
        config = {
          allowUnfree = true;
        };
      };
      unstablePkgs = import nixpkgs-unstable {
        system = system;
        config = pkgs.config;
      };
    in {
      nixosConfigurations.nixops = pkgs.nixosSystem {
        system = system;
        modules = [
          ./configuration.nix
          {
            nixpkgs = pkgs;
            unstablePkgs = unstablePkgs;
          }
        ];
      };
    };
}
