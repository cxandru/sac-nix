{
  description = "SaC Compiler and Stdlib";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    # sac is currently only build for linux (and macos... this
    # will be added later here)
    #flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      sacVCs = {
        version = "1.3.3";
        vname = "MijasCosta";
        changes = "709";
        rev = "1";
        commit = "g8fa2";
      };
      stdlibVCs = {
        version = "1.3";
        changes = "137";
        commit = "g1cad5";
      };
      sac-compiler = pkgs.callPackage ./sac2c { inherit sacVCs sac-stdlib; };
      sac-stdlib = pkgs.callPackage ./stdlib { inherit sacVCs stdlibVCs; };
      in {
        packages.x86_64-linux.sac2c = sac-compiler;
        packages.x86_64-linux.stdlib = sac-stdlib;
        defaultPackage.x86_64-linux = self.packages.x86_64-linux.sac2c;
      }
      #)
      ;
}
