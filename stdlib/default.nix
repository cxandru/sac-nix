{ fetchurl, stdenv }:

stdenv.mkDerivation rec {
  pname = "sacStdLib";
  sacVersion = "1.3.3-552-1"; #Fixme: This should be shared
  version = "1.3";
  commits = "102";
  hash = "gf229";
  name = "${pname}-${version}-${commits}-${hash}";
  src = pkgs.fetchurl {
    url = "https://gitlab.science.ru.nl/sac-group/sac-packages/-/raw/master/packages/weekly/Linux/${sacVersion}/basic/sac-stdlib-${version}-${commits}-${hash}.tar.gz";
    sha256 = "3ca62cabdcb33589a635d82e6d418d3153f6ade1eec59a21352d31648d2a6411";
  };
  buildInputs = [ sac2c ];
};
