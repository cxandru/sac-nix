{ stdenv, fetchurl, perl, autoconf, automake, libtool, pkg-config }:

stdenv.mkDerivation rec {
  pname = "libxcrypt";
  version = "4.4.18";
  nativeBuildInputs = [ perl autoconf automake libtool pkg-config ];

  preConfigure = ''
    ./autogen.sh
  '';
  #to install libcrypt.so.2 instead of libcrypt.so.1
  configureFlags = [ "--disable-obsolete-api" ];
  src = fetchurl {
    url = "https://github.com/besser82/libxcrypt/archive/94d84f92ca123d851586016c4678eb1f21c19029.tar.gz";
    sha256 = "061vxrmmdqgz45i6a95cl72clp4jan6h5lvl6spxnzq8jwj2npbw";
  };
}
