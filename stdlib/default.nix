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
    sha256 = "68a544498659f7048c3dc59db033f3bc68309d999aab75024fab7fccf02fc75f";
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
