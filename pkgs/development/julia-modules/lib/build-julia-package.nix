{ stdenv
, lib
, cacert
, julia
, makeJuliaPath
, deepReq
}:

lib.makeOverridable (
{ pname
, version
, requires ? []
, buildInputs ? []
, propagatedBuildInputs ? []
, checkInputs ? []
, doCheck ? true
, ... } @ attrs:

let
  _buildInputs = [ julia ] ++ buildInputs ++ lib.optionals doCheck checkInputs;
  LD_LIBRARY_PATH = lib.makeLibraryPath _buildInputs;

  # All ancestral packages in the dependency graph are required
  _allRequires = deepReq requires;
  JULIA_DEPOT_PATH = makeJuliaPath _allRequires;

in stdenv.mkDerivation (attrs // {

  name = "julia-${julia.version}-${pname}-${version}";

  buildInputs = _buildInputs ++ _allRequires;
  propagatedBuildInputs = [ julia ] ++ propagatedBuildInputs;

  inherit LD_LIBRARY_PATH JULIA_DEPOT_PATH;

  configurePhase = ''
    runHook preConfigure

    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    export JULIA_DEPOT_PATH="${JULIA_DEPOT_PATH}"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
    export JULIA_PKGDIR="$out/share/julia/site"

    runHook postConfigure
  '';

  # We only need to build when deps/build.jl exists. Otherwise, we have a pure Julia package
  # that can be used straight away.
  # https://docs.julialang.org/en/release-0.5/stdlib/pkg/#Base.Pkg.build
  buildPhase = ''
    runHook preBuild

    if [ -f "deps/build.jl" ]; then
      julia deps/build.jl
    fi

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/${julia.site}/${pname}"
    cp -R . "$out/${julia.site}/${pname}"

    runHook postInstall
  '';

  # Run tests. We disable tests explicitly when they're not provided.
  # https://docs.julialang.org/en/release-0.5/stdlib/pkg/#Base.Pkg.test
  checkPhase = ''
    runHook preCheck

    julia test/runtests.jl

    runHook postCheck
  '';


  passthru = {
    inherit julia;
  };

}))
