{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = import ./lib;
      in
      {
        inherit lib;

        checks = {
          json = pkgs.callPackage ./tests/json { inherit pkgs lib; };
          pre-commit = pkgs.callPackage ./tests/pre-commit { inherit pkgs lib; };
          text = pkgs.callPackage ./tests/text { inherit pkgs lib; };
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.cue
            pkgs.nixpkgs-fmt
          ];
        };
      }
    );
}
