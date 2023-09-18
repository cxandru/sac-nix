{
  description = "SaC Compiler and Stdlib";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-compat }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      sacVCs = {
        version = "1.3.3";
        vname = "MijasCosta";
        changes = "1079";
        rev = "1";
        commit = "g648dba";
      };
      stdlibVCs = {
        version = "1.3";
        changes = "152";
        commit = "gaa99";
      };
      sac-compiler = pkgs.callPackage ./sac2c { inherit sacVCs sac-stdlib; };
      sac-stdlib = pkgs.callPackage ./stdlib { inherit sacVCs stdlibVCs; };
      in {
        packages.x86_64-linux.sac2c = sac-compiler;
        packages.x86_64-linux.stdlib = sac-stdlib;
        defaultPackage.x86_64-linux = self.packages.x86_64-linux.sac2c;
      };
}
