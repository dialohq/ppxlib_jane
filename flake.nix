{
  description = "typerep dupa";

  inputs = {
    nixpkgs.url = "github:nixOs/nixpkgs/96bf45e4c6427f9152afed99dde5dc16319ddbd6";
    flake-utils.url = "github:numtide/flake-utils/c1dfcf08411b08f6b8615f7d8971a2bfa81d5e8a";
    ocaml-overlay.url = "git+file:///Users/adam/Documents/Programming/libs/nix-overlays";
    ocaml-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ocaml-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            ocaml-overlay.overlays.default
            (self: super: {ocamlPackages = super.ocaml-ng.ocamlPackages_5_3;})
          ];
        };
      in rec {
        packages.default = pkgs.ocamlPackages.buildDunePackage {
          pname = "ppxlib_jane";
          version = "1.0.0";
          src = ./.;
          buildInputs = with pkgs.ocamlPackages; [ppxlib];
        };
        devShells.default = pkgs.mkShell {
          packages = [pkgs.alejandra pkgs.ocamlPackages.ocaml-lsp];
          inputsFrom = [packages.default];
        };
      }
    );
}
