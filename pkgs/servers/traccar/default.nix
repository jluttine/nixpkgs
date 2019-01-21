{ stdenv, fetchFromGitHub, maven, fetchurl, callPackage, runCommand, makeWrapper
, mavenix ? callPackage (import (fetchurl {
    url = https://raw.githubusercontent.com/icetan/mavenix/b7b08c42659768af33397226ac05c9cd7709119a/mavenix.nix;
    sha256 = "0p83kr3gxzk54g95zah31wd88jd2fysbv79xw942457w94n26nk3";
  })) {}
}: let
  pname = "traccar";
  version = "4.2";

  src = fetchFromGitHub {
    repo = pname;
    owner = "traccar";
    rev = "v${version}";
    sha256 = "1xqnqz53h5yw5l1qc2mi35pnwihjfwpfccy86wl6jphl968w1czn";
    fetchSubmodules = true;
  };

  jar = mavenix {
    inherit maven src;
    infoFile = ./mavenix-info.json;
    postInstall = ''
      cp -vr target/lib $out/share/java/lib
    '';
  };
in runCommand "${pname}-${version}" {
  buildInputs = [ makeWrapper ];
  meta = with stdenv.lib; {
    description = "Modern GPS tracking platform";
    homepage = https://www.traccar.org/;
    license = licenses.asl20;
    maintainers = with maintainers; [ jluttine ];
    platforms = platforms.linux;
  };
} ''
  mkdir -p $out/bin
  makeWrapper ${maven.jdk}/bin/java $out/bin/traccar \
    --add-flags "-jar ${jar.build}/share/java/tracker-server.jar"
''

