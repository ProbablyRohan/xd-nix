{
  description = "Flake providing a home-manager module for XD";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

  in {
    homeManagerModules.default = import ./module.nix;
  };
}
