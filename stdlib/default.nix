{ lib, fetchurl, stdenv, sacVCs, stdlibVCs }:

let
  sacVersion = with sacVCs; "${version}-${changes}-${rev}";
  versionedPathSegment = with sacVCs; "sac2c/${version}-${vname}-${changes}-${commit}";
in
stdenv.mkDerivation rec {
  inherit (stdlibVCs) version changes commit;
  pname = "sacStdLib";
  name = "${pname}-${version}-${changes}-${commit}";
  src = fetchurl {
    url = "https://gitlab.sac-home.org/sac-group/sac-packages/-/raw/master/packages/weekly/Linux/${sacVersion}/basic/sac-stdlib-${version}-${changes}-${commit}.tar.gz";
    sha256 = "f1ad920c8b0f6e41f6425f530aeb9a3869037081b97e914c5fb5b8cd9bf5fc26";
  };
  #We get rid of the versioned path segments as in nix versioning is in the prefix
  installPhase = ''
    mkdir $out
    mv usr/local/libexec/${versionedPathSegment} $out/libexec
    mv usr/local/lib/${versionedPathSegment} $out/lib
  '';

  meta = with lib; {
    description = "The standard library for the Single-Assignment C programming language";
    homepage = "http://www.sac-home.org/";
    license = ../pkg-LICENSE.txt;
  };
}
