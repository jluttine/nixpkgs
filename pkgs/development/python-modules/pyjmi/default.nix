{ stdenv, buildPythonPackage, fetchsvn, python, numpy, scipy, matplotlib,
cython, lxml, assimulo, pyfmi, fmilibrary, pymodelica, jmodelica, JPype1,
openjdk, nose, gfortran, gcc }:

buildPythonPackage rec {

  pname = "pyjmi";
  version = "2.4";

  src = fetchsvn {
    url = "https://svn.jmodelica.org/tags/${version}";
    rev = "12326"; #version;
    sha256 = "0fxc4664k5armwv5y7d4cxnskbd31ys65y3s32h9rlq5hd1ddzrl";
  };
  # src = fetchsvn {
  #   url = "https://svn.jmodelica.org/tags/${version}/Python/src/";
  #   rev = "12326";
  #   sha256 = "124r8ypb749mbl41610ixcq2s9ramcspfihjzsci141rwx9p47yh";
  # };

  prePatch = ''
    cd Python/src/
    mv setup_pyjmi.py setup.py
  '';

  JMODELICA_HOME = "${jmodelica}";

  checkInputs = [ nose gfortran gcc ];

  propagatedBuildInputs = [ numpy scipy matplotlib pyfmi JPype1 pymodelica openjdk ];

  # postInstall = ''
  #   cp ${jmodelica}/Python/required_defaults.py $out/lib/${python.libPrefix}/site-packages/
  # '';

  # doCheck = false;

  # Remove the source trees so that the unit tests will be run against the installed packages
  checkPhase = ''
    rm -r common pyjmi pymodelica setup_*.py startup.py
    nosetests
  '';

  # meta = with stdenv.lib; {
  #   homepage = https://jmodelica.org/pyfmi/;
  #   description = "Package for loading and interacting with Functional Mock-Up Units (FMUs)";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jluttine ];
  # };
}
