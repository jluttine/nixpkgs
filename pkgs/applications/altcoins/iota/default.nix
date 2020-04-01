{ stdenv, fetchFromGitHub, electron }:

let
  version = "2.5.4";
in
stdenv.mkDerivation rec {
  name = "iota-${version}";

  src = fetchFromGitHub {
    owner = "iotaledger";
    repo = "wallet";
    rev = "v${version}";
    sha256 = "8nrpxx6r63ia6ard85d504x2kgaikvrhb5sg93ml70l6djyy1148";
  };

  nativeBuildInputs = [ ];

  buildInputs = [ electron ];

  meta = with stdenv.lib; {
    description = "Cryptocurrency for the Internet of things";
    homepage = https://iota.org/;
    license = licenses.gpl3;
    maintainers = [ maintainers.jluttine ];
  };
}
