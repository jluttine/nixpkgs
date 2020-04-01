{ stdenv, buildPythonPackage, fetchsvn, fetchurl, gfortran, jdk, ipopt, ant, cmake
, numpy, scipy, cython, python, sundials }:

let

  # Assimulo requires Sundials 2.5/2.6
  sundials26 = sundials.overrideDerivation (
    attrs: rec {
      name = "${attrs.pname}-${version}";
      version = "2.6.2";
      src = fetchurl {
        url = "https://computation.llnl.gov/projects/${attrs.pname}/download/${attrs.pname}-${version}.tar.gz";
        sha256 = "0bsdmal7sq90ih5hihqg6isa35cbbwbs865k2zrv1llxa18h3vfq";
      };
    }
  );

in buildPythonPackage rec {

  pname = "jmodelica";
  version = "2.4";

  src = fetchsvn {
    url = "https://svn.jmodelica.org/tags/${version}";
    rev = "12326"; #version;
    #sha256 = "071l40mghm4rcic39lkqm74x5cvjc1z8idzfp0ik0lmczaqxklgl";
    sha256 = "0fxc4664k5armwv5y7d4cxnskbd31ys65y3s32h9rlq5hd1ddzrl";
  };

  # NIX_LDFLAGS = "-lSDL_image";

  # buildInputs = [ SDL SDL_image libGLU_combined openal libvorbis freealut ];

  postPatch = ''
    substituteInPlace get_version.sh --replace /bin/bash /bin/sh
    substituteInPlace run_java.sh --replace /bin/bash /bin/sh
    substituteInPlace RuntimeLibrary/Makefiles/Makefile.linux --replace \
      "\$(EXT_LIB_DIRS)" "-L${gfortran.cc.lib}/lib -L${sundials26}/lib \$(EXT_LIB_DIRS)"
  '';

  # A lot of references to /usr/bin/file..

  # dontUseCmakeConfigure = true;

  # configureFlags = ["--with-ipopt64=${ipopt}"];

  # Maybe sufficient to make only these:
  # make mc_modelica
  # make mc_optimica
  # make build-python-packages  # hmmm.. this builds external python stuff too..
  # make build-compiler


  buildInputs = [
    gfortran
    ant
    cmake
    jdk
    numpy
    scipy
    cython
    sundials26
  ];

  configurePhase = ''
    runHook preConfigure
    ./configure --with-ipopt64=${ipopt} --prefix=$out --enable-shared --disable-static
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    pushd Python
    make
    popd
    pushd RuntimeLibrary
    make
    popd
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    pushd Python
    make install
    popd
    pushd RuntimeLibrary
    make install
    popd
    runHook postInstall
  '';

  postInstall = ''
    mkdir -p $out/lib/${python.libPrefix}
    mv $out/Python $out/lib/${python.libPrefix}/site-packages
  '';

  doCheck = false;

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



  meta = with stdenv.lib; {
    homepage = http://jmodelica.org/;
    description = "Modelica-based platform for optimization, simulation and analysis of complex dynamic systems";
    license = licenses.gpl3;
    maintainers = with maintainers; [jluttine];
    #platforms = with platforms; linux;
  };
}
