{
  description = "SAC development environment";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in with pkgs;
      rec {
        # TODO: should this be smtng like sac.compiler?
        sac2c = callPackage ./sac2c { inherit sacStdLib; };
        sacStdLib = callPackage ./stdlib {};
      };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.sac2c;
  };
}
