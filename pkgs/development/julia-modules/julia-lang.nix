# Main file

{ stdenv
, julia
, callPackage
}:

rec {

  buildEnv = callPackage ./build-env.nix {
    inherit (pkgs) isJuliaPackage makeJuliaPath deepReq;
  };

  withPackages = f:
    let p = f pkgs; in buildEnv { packages = p; };

  pkgs = callPackage ./. { };
}

