{ stdenv, fetchFromGitHub, jdk, gradle }:

stdenv.mkDerivation rec {
  pname = "libdecsync";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "39aldo39";
    repo = pname;
    rev = "v${version}";
    sha256 = "0vij9vrcb2h11i3i4ffambp39hl1v7xr2c1nzy1ldlij5rprh7ll";
  };

  postPatch = ''
    substituteInPlace ./gradlew --replace "#!/usr/bin/env sh" "#!/bin/sh"
  '';

  nativeBuildInputs = [ jdk gradle ];
}
