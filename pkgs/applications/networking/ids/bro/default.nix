{stdenv, fetchurl, cmake, flex, bison, openssl, libpcap, perl, zlib, file, curl
, geoip, gperftools, python, swig }:

stdenv.mkDerivation rec {
  name = "bro-2.5.1";

  src = fetchurl {
    url = "http://www.bro.org/downloads/${name}.tar.gz";
    sha256 = "04cmm0vs8q31mgaq3pxybjk834py3ji16qp4qcir7vjbhq1fav1c";
  };

  nativeBuildInputs = [ cmake flex bison file ];
  buildInputs = [ openssl libpcap perl zlib curl geoip gperftools python swig ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Powerful network analysis framework much different from a typical IDS";
    homepage = https://www.bro.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [ pSub ];
    platforms = with platforms; linux;
  };
}
