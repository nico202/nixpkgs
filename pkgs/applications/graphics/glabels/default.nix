{ stdenv, fetchFromGitHub, autoconf, automake, which, pkgconfig, makeWrapper,
  intltool, itstool, gtk3, libxml2, librsvg, gtk_doc, libtool,
  libe-book, barcode, gnome3}:

stdenv.mkDerivation rec {
  name = "glabels-${version}";
  version = "3.2.1";
  src = fetchFromGitHub {
    owner = "jimevins";
    repo = "glabels";
    rev = "940153cb1e3da33882f89926e590979cea27337a";
    sha256 = "0d1x2yalfjwbl8pjqnw9am3xcjfny596m1s5cn2j534h4whjca2q";
  };

  buildInputs =
    [ intltool itstool gtk3 libxml2 librsvg
    libe-book barcode libtool gnome3.gsettings_desktop_schemas
    gnome3.gnome_common pkgconfig makeWrapper
    ];

  propagatedBuildInputs = [ autoconf automake gtk_doc gnome3.yelp_tools];

  preFixup = ''
    rm "$out/share/icons/hicolor/icon-theme.cache"
    wrapProgram "$out/bin/glabels-3" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  meta = {
    description = "Create labels and business cards";
    homepage = http://glabels.org/;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.unix;
  };
}
