{ lib, stdenv, fetchurl, glibc, libuuid, gcc, binutils, sacStdLib }:

stdenv.mkDerivation rec {
        name = "${pname}-${version}-${vname}-${commit}-${rev}";
        pname = "sac2c";
        version = "1.3.3";
        rev = "1";
        changes = "552";
        vname = "MijasCosta";
        commit = "g630ef";
        src = pkgs.fetchurl {
          url = "https://gitlab.science.ru.nl/sac-group/sac-packages/-/raw/master/packages/weekly/Linux/${version}-${changes}-${rev}/basic/${pname}-${version}-${vname}-${changes}-${commit}-omnibus.tar.gz";
          sha256 = "61ad03f16a4a13c8094bce016d9105979db3c6868120d156d908c1c011a6958d";
        };
        #https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos/522823#522823
        #https://nixos.wiki/wiki/Packaging/Binaries
        #TODO: do patchelf manually w/ rpath:
        rpath = pkgs.lib.makeLibraryPath [
          pkgs.glibc
          pkgs.libuuid
        ];
        #libutils for ranlib: https://manpages.debian.org/jessie/binutils/index.html
        sourceRoot = "src";
        makeFile = ./Makefile
        sac2cBinaries = [ "csima" "csimt" "sac2c" "sac2tex" "sac4c" "saccc" ];
        versionedPathSegment = "${pname}/${version}-${vname}-${changes}-${commit}";
        binPostfix = "_p";
        debugPostfix = "_d";
        preBuild = ''
          for postFix in ${binPostfix} ${debugPostfix}; do
          substituteInPlace share/${versionedPathSegment}/sac2crc$postFix \
            --replace /usr/sbin/cc ${pkgs.gcc}/bin/cc \
            --replace /usr/sbin/ranlib ${pkgs.binutils}/bin/ranlib \
            --replace /usr/local/ $out/
          substituteInPlace libexec/${versionedPathSegment}/saccc$postFix \
            --replace /usr/sbin/bash ${pkgs.bash}/bin/bash
          done
          for postFix in release debug; do
          substituteInPlace installers/installer-''${postFix}.sh \
            --replace /usr/local $out/
          done
        '';
        installPhase = ''
         mkdir $out
         bash ./install.sh -i $out
         cd $out
         mkdir bin
         for binary in ${builtins.toString sac2cBinaries}; do
         ln -s "$out/libexec/${versionedPathSegment}/''${binary}${binPostfix}" bin/$binary
         done
       '';
        #https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/instant-messengers/skypeforlinux/default.nix
        # for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* \) ); do
        # patchelf --set-rpath ${rpath}:${binPrefix} $file || true

        meta = with lib; {
          description = "A program that produces a familiar, friendly greeting";
          longDescription = ''
      GNU Hello is a program that prints "Hello, world!" when you run it.
      It is fully customizable.
    '';
          homepage = "https://www.gnu.org/software/hello/manual/";
          changelog = "https://git.savannah.gnu.org/cgit/hello.git/plain/NEWS?h=v${version}";
          license = licenses.gpl3Plus;
          maintainers = [ maintainers.eelco ];
          platforms = platforms.all;
        };
};


