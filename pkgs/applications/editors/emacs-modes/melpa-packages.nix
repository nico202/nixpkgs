/*

# Updating

To update the list of packages from MELPA,

1. Clone https://github.com/ttuegel/emacs2nix
2. Clone https://github.com/milkypostman/melpa
3. Run `./melpa-packages.sh PATH_TO_MELPA_CLONE` from emacs2nix
4. Copy the new melpa-packages.json file into Nixpkgs
5. `git commit -m "melpa-packages $(date -Idate)"`

*/

{ lib }:

let

  inherit (lib) makeScope mapAttrs;

  json = builtins.readFile ./melpa-packages.json;
  manifest = builtins.fromJSON json;

  mkPackage = self: name: recipe:
    let drv =
          { melpaBuild, stdenv, fetchbzr, fetchcvs, fetchFromGitHub, fetchFromGitLab
          , fetchgit, fetchhg, fetchsvn, fetchurl }:
          let
            unknownFetcher =
              abort "emacs-${name}: unknown fetcher '${recipe.fetch.tag}'";
            fetch =
              {
                inherit fetchbzr fetchcvs fetchFromGitHub fetchFromGitLab fetchgit fetchhg
                        fetchsvn fetchurl;
              }."${recipe.fetch.tag}"
              or unknownFetcher;
            args = builtins.removeAttrs recipe.fetch [ "tag" ];
            src = fetch args;
            recipeFile = fetchurl {
              url = "https://raw.githubusercontent.com/milkypostman/melpa/${recipe.recipe.commit}/recipes/${name}";
              inherit (recipe.recipe) sha256;
            };
          in melpaBuild {
            pname = name;
            inherit (recipe) version;
            inherit recipeFile src;
            packageRequires =
              let lookupDep = d: self."${d}" or null;
              in map lookupDep recipe.deps;
            meta = {
              homepage = "http://melpa.org/#/${name}";
              license = stdenv.lib.licenses.free;
            };
          };
    in self.callPackage drv {};

in

self:

  let
    super = mapAttrs (mkPackage self) manifest;

    markBroken = pkg: pkg.override {
      melpaBuild = args: self.melpaBuild (args // {
        meta = (args.meta or {}) // { broken = true; };
      });
    };

    melpaPackages = super // {
      # broken upstream
      ack-menu = markBroken super.ack-menu;
    };
  in
    melpaPackages // { inherit melpaPackages; }
