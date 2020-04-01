{ stdenv, fetchsvn, gfortran, jdk, ipopt, ant, cmake, python27, bash }:

let
  python = python27;
in stdenv.mkDerivation rec {

  pname = "jmodelica";
  version = "2.4";

  src = fetchsvn {
    url = "https://svn.jmodelica.org/tags/${version}";
    rev = "12326"; #version;
    sha256 = "0fxc4664k5armwv5y7d4cxnskbd31ys65y3s32h9rlq5hd1ddzrl";
  };

  # NIX_LDFLAGS = "-lSDL_image";

  # buildInputs = [ SDL SDL_image libGLU_combined openal libvorbis freealut ];

  postPatch = ''
    substituteInPlace get_version.sh --replace /bin/bash ${bash}/bin/bash
    substituteInPlace run_java.sh --replace /bin/bash ${bash}/bin/bash
  '';

  dontUseCmakeConfigure = true;

  configureFlags = ["--with-ipopt64=${ipopt}"];

  # CONTINUE FROM HERE:

  # nix-shell -p python jmodelica pythonPackages.numpy pythonPackages.scipy  pythonPackages.lxml pythonPackages.JPype1 openjdk pythonPackages.matplotlib pythonPackages.jupyter

  # JMODELICA_HOME=/nix/store/0f8nc67nh1sib3xawidlgw2gb57g5fhl-jmodelica-2.4 python

  # >>> from pyjmi.examples import RLC
  # >>> RLC.run_demo()

  # WARNING:root:The environment variable SEPARATE_PROCESS_JVM is not set. Trying JAVA_HOME instead.
  # /nix/store/3xwc1ip20b0p68sxqbjjll0va4pv5hbv-binutils-2.30/bin/ld: cannot find -lgfortran
  # /nix/store/3xwc1ip20b0p68sxqbjjll0va4pv5hbv-binutils-2.30/bin/ld: cannot find -l:libsundials_kinsol.a
  # /nix/store/3xwc1ip20b0p68sxqbjjll0va4pv5hbv-binutils-2.30/bin/ld: cannot find -l:libsundials_nvecserial.a
  # /nix/store/3xwc1ip20b0p68sxqbjjll0va4pv5hbv-binutils-2.30/bin/ld: cannot find -l:libsundials_cvode.a



  buildInputs = [
    bash
    gfortran
    ant
    cmake
    jdk
    (python27.withPackages (ps: with ps; [ps.numpy ps.scipy ps.cython]))
  ];
  # patchPhase = ''
  #   sed -i -e s,Data/,$out/opt/$name/Data/,g \
  #     -e s,Data:,$out/opt/$name/Data/,g \
  #     Source/*.cpp
  # '';

  # installPhase = ''
  #   mkdir -p $out/bin $out/opt/$name
  #   cp objs/blackshades $out/bin
  #   cp -R Data IF* Readme $out/opt/$name/
  # '';

  postInstall = ''
    mkdir -p $out/lib/${python.libPrefix}
    mv $out/Python $out/lib/${python.libPrefix}/site-packages
  '';

  meta = with stdenv.lib; {
    homepage = http://jmodelica.org/;
    description = "Modelica-based platform for optimization, simulation and analysis of complex dynamic systems";
    license = licenses.gpl3;
    maintainers = with maintainers; [jluttine];
    #platforms = with platforms; linux;
  };
}
