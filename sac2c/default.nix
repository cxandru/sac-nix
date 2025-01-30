{ lib, pkgs, stdenv, fetchurl,
glibc, libuuid, gcc, binutils,
  sacVCs, sac-stdlib,
  bash, autoPatchelfHook
}:

stdenv.mkDerivation rec {

  inherit (sacVCs) version vname changes rev commit;

  pname = "sac2c";
  name = "${pname}-${version}-${vname}-${commit}-${rev}";
  src = fetchurl {
    url = "https://gitlab.sac-home.org/sac-group/sac-packages/-/raw/master/packages/weekly/Linux-x86_64/${version}-${changes}-${rev}/basic/${pname}-${version}-${vname}-${changes}-${commit}-omnibus.tar.gz";
    hash = "sha256-S71aHQapqmylD/eUYncrjyoOwF9ZEwl8veYR0mcy02I=";
  };

  # standard libxcrypt installs libxcrypt.so.1 by default, but this isn't the form of
  # the lib that sac2c is linked to. So we change this so that we install in libxcrypt.so.2
  # instead (which is standard on other systems).
  mylibxcrypt = pkgs.libxcrypt.overrideAttrs (old: {
    version = "4.4.27";
    src = pkgs.fetchurl {
      url = "https://github.com/besser82/libxcrypt/releases/download/v4.4.38/libxcrypt-4.4.38.tar.xz";
      sha256 = "sha256-gDBLnDBup5kyfwHZp1Sb2ygxd4kYJjHxtU9FEbQgbdY=";
    };
    preConfigure = ''
      patchShebangs --build configure
      patchShebangs build-aux/scripts
      '';
    configureFlags = [ "--disable-obsolete-api" ];
  });

  nativeBuildInputs = [ autoPatchelfHook ];
  #libuuid.so.1, libcrypt.so.2
  buildInputs = [ libuuid mylibxcrypt ];
  #https://nixos.wiki/wiki/Packaging/Binaries
  #TODO: Use this instead of autoPatchElf
  rpath = lib.makeLibraryPath [
    glibc
    libuuid
  ];
  #Don't cd directly after unpacking
  sourceRoot = ".";
  makefile = ./Makefile;
  versionedPathSegment = "${pname}/${version}-${vname}-${changes}-${commit}";
  prodPostfix = "_p";
  debugPostfix = "_d";
  dontConfigure = true;
  #sed magic:
  #https://www.grymoire.com/Unix/Sed.html#uh-42
  #https://stackoverflow.com/questions/18620153/find-matching-text-and-replace-next-line
  #We set outputdirs to "". This means the -install flag to the compiler won't work.
  #We need to add both stdLib and sac2c paths because in the normie install, those dirs are shared (what a horrible thought!)
  #It seems the !b... command messes up any replacements following it (!)
  buildPhase = ''
    #We get rid of the versioned path segments as in nix versioning is in the prefix
    for dir in include lib libexec share; do
    mv $dir/${versionedPathSegment} ''${dir}_n
    rmdir -p $dir/sac2c
    mv ''${dir}_n $dir
    done
    for postFix in ${prodPostfix} ${debugPostfix}; do
    substituteInPlace share/sac2crc$postFix \
      --replace /usr/sbin/cc ${gcc}/bin/cc \
      --replace /usr/sbin/ranlib ${binutils}/bin/ranlib
    replaceNextCmds='!b;n;c'
    sed -e "
    /SACINCLUDES      :=/ c\
    SACINCLUDES      :=  \"-I$out/include/release\"
    " -e "
    /EXTLIBPATH       :=/ c\
    EXTLIBPATH       :=  \"\"
    " -e "
    /TREEPATH         :=  \".:\"/ c\
    TREEPATH         :=  \".:${sac-stdlib}/libexec:$out/libexec:\"
    " -e '
    /LIB_OUTPUTDIR    :=/ c\
    LIB_OUTPUTDIR    :=  ""
    ' -e '
    /TREE_OUTPUTDIR   :=/ c\
    TREE_OUTPUTDIR   :=  ""
    ' -e "
    /LIBPATH          :=/$replaceNextCmds\
                         \"${sac-stdlib}/lib/modlibs:$out/lib/modlibs:$out/lib/rt:\"
    " -i share/sac2crc$postFix
    substituteInPlace libexec/saccc$postFix \
      --replace /usr/sbin/bash ${bash}/bin/bash
    done
    sed -e "
    /#define SAC2CRC_DIR / c\
    #define SAC2CRC_DIR \"$out/share\"
    " -e "
    /#define DLL_DIR / c\
    #define DLL_DIR \"$out/libexec\"
    " -i src/sacdirs.h

    #Actual Build
    cd src
    make -f ${makefile}
    cd ..
  '';

  installPhase = ''
    find src -type f -executable -exec bash -c 'mv "$0" -t libexec' {} \;
    mkdir $out
    for dir in share include lib libexec; do
    mv $dir $out/$dir
    done
    cd $out
    mkdir bin
    for binary in csima csimt sac2c sac2tex sac4c saccc; do
    ln -s "$out/libexec/''${binary}${prodPostfix}" bin/$binary
    for postFix in ${prodPostfix} ${debugPostfix}; do
    ln -s "$out/libexec/$binary$postFix" bin/$binary$postFix
    done
    done
  '';
  meta = with lib; {
    description = "The compiler (sac2c) of the Single-Assignment C programming language";
    homepage = "http://www.sac-home.org/";
    #changelog = ??
    license = [ ../pkg-LICENSE.txt ];
  };
}
