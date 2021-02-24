{
  description = "SAC development environment";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = { flake-utils, self, nixpkgs }:
    flake-utils.lib.eachDefaultSystem ( system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        with pkgs; rec {
          packages = flake-utils.lib.flattenTree rec {
            # TODO: should this be smtng like sac.compiler?
            sac2c = callPackage ./sac2c { inherit sacStdLib; };
            sacStdLib = callPackage ./stdlib {};
          };
          defaultPackage = packages.sac2c;
          apps.repl =
            flake-utils.lib.mkApp {
              drv = pkgs.writeShellScriptBin "repl" ''
              confnix=$(mktemp)
              echo "builtins.getFlake (toString $(git rev-parse --show-toplevel))" >$confnix
              trap "rm $confnix" EXIT
              nix repl $confnix
            '';
            };
        }
    );
}
