SaC NixOS Packages
==================

This repository provides NixOS specifications for configuring and installing
the SaC compiler and standard library. Doing `nix build` should get you going!

Extra detail
------------

The compiler depends on `libxcrypt`, but the version provided by NixOSPkgs
uses the _obsolete_ configuration. As such in the `sac2c/default.nix` recipe
we override this.
