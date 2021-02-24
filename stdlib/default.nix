{ lib, fetchurl, stdenv, sacVCs }:

let
  sacVersion = with sacVCs; "${version}-${changes}-${rev}";
  versionedPathSegment = with sacVCs; "sac2c/${version}-${vname}-${changes}-${commit}";
in
stdenv.mkDerivation rec {
  pname = "sacStdLib";
  version = "1.3";
  changes = "102";
  commit = "gf229";
  name = "${pname}-${version}-${changes}-${commit}";
  src = fetchurl {
    url = "https://gitlab.science.ru.nl/sac-group/sac-packages/-/raw/master/packages/weekly/Linux/${sacVersion}/basic/sac-stdlib-${version}-${changes}-${commit}.tar.gz";
    sha256 = "3ca62cabdcb33589a635d82e6d418d3153f6ade1eec59a21352d31648d2a6411";
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
  };
}
