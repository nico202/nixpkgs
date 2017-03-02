{ stdenv, fetchurl, unzip, libusb, fetchgit }:
let
  version = "2.1";
in
stdenv.mkDerivation {
  name = "teensy-loader-cli-${version}";
  src = fetchgit {
    url = "git://github.com/PaulStoffregen/teensy_loader_cli.git";
    rev = "f7a728c5a0754ec741f709e2db28eee87fc3201f";
    sha256 = "17ajlsl76zw22c0838zm3w1ilczcrhcf3xd6iwjjk8nrnizkiana";
  };

  buildInputs = [ unzip libusb ];

  installPhase = ''
    install -Dm755 teensy_loader_cli $out/bin/teensy-loader-cli
  '';

  meta = with stdenv.lib; {
    license = licenses.gpl3;
    description = "Firmware uploader for the Teensy microcontroller boards";
    homepage = http://www.pjrc.com/teensy/;
    maintainers = with maintainers; [ the-kenny ];
    platforms = platforms.linux;
  };
}
