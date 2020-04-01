{ stdenv, buildPythonPackage, fetchsvn, python, numpy, scipy, cython, lxml,
assimulo, fmilibrary, jmodelica, nose }:

buildPythonPackage rec {

  pname = "pymodelica";
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
    mv setup_pymodelica.py setup.py
  '';

  postInstall = ''
    cp ${jmodelica}/lib/${python.libPrefix}/site-packages/required_defaults.py $out/lib/${python.libPrefix}/site-packages/
    #cp ${jmodelica}/Python/required_defaults.py $out/lib/${python.libPrefix}/site-packages/
  '';

  doCheck = false;
  # checkPhase = ''
  # '';

  # meta = with stdenv.lib; {
  #   homepage = https://jmodelica.org/pyfmi/;
  #   description = "Package for loading and interacting with Functional Mock-Up Units (FMUs)";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jluttine ];
  # };
}
