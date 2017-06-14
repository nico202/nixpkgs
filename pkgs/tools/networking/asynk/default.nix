{ stdenv, fetchurl, python2, python2Packages, makeWrapper }:

stdenv.mkDerivation rec {
  version = "2.2.0";
  name = "ASynK-${version}";

  src = fetchurl {
    name = "${name}.tar.gz";
    url = "https://github.com/skarra/ASynK/archive/v${version}.tar.gz";
    sha256 = "13zx2cvm2i7b1nqkq538nv48qriz4widzi3bmw9byir10jwjg3gy";
  };

  propagatedBuildInputs = with python2Packages;
    [ python2 makeWrapper tornado dateutil
      httplib2 google_api_python_client
      vobject gdata caldavclientlibrary-asynk ];

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp asynk.py $out/bin/
    cp state.init.json $out/
    cp -R config $out/
    cp lib/*.py $out/lib # */
    cp -R lib/s $out/lib/
    cp -R asynk $out/

    substituteInPlace $out/bin/asynk.py \
      --replace "ASYNK_BASE_DIR    = os.path.dirname(os.path.abspath(__file__))" "ASYNK_BASE_DIR    = \"$out\""

    for file in `find $out/asynk -type f`; do
      # Oh yeah, tab characters!
      substituteInPlace $file \
        --replace 'from   vobject        import vobject' 'from vobject import *' \
        --replace 'from   vobject    import vobject' 'from vobject import *'
    done

    wrapProgram "$out/bin/asynk.py" \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  meta = with stdenv.lib; {
    homepage = http://asynk.io/;
    description = "Flexible contacts synchronization program";
    license = licenses.agpl3;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}
