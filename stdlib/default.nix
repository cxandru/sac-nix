{ lib, fetchurl, stdenv }:

stdenv.mkDerivation rec {
  pname = "sacStdLib";
  #Fixme: These should be shared w/ sac2c
  sacVersion = "1.3.3-552-1";
  versionedPathSegment = "sac2c/1.3.3-MijasCosta-552-g630ef";
  #
  version = "1.3";
  commits = "102";
  hash = "gf229";
  name = "${pname}-${version}-${commits}-${hash}";
  src = fetchurl {
    url = "https://gitlab.science.ru.nl/sac-group/sac-packages/-/raw/master/packages/weekly/Linux/${sacVersion}/basic/sac-stdlib-${version}-${commits}-${hash}.tar.gz";
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
