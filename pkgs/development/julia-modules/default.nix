{ stdenv
, julia
, pkgs
, overrides ? (self: super: {})
}:

let

#   official-packages = map buildOfficialJuliaPackage builtins.fromJSON (builtins.readFile ./packages.json);

  inherit (stdenv.lib) fix' extends;


  lib = pkgs.callPackage ./lib.nix { julia = julia; };

  official-packages = self: super: {};

  common-overrides = pkgs.callPackage ./common-overrides.nix { julia = julia; };

in fix' (extends overrides (extends common-overrides (extends official-packages lib)))
