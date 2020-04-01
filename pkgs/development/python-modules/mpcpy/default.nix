{ stdenv, buildPythonPackage, fetchFromGitHub, isPy27, numpy, pandas,
matplotlib, dateutil, pytz, scikitlearn, tzwhere, JPype1, openjdk, pyfmi,
pymodelica, fmilibrary, shapely, geos, gfortran, gfortran49, gcc, jupyter,
ipython, jmodelica, ipopt, sundials }:

buildPythonPackage rec {
  pname = "mpcpy";

  # Latest release is very old.
  version = "unstable-2019-01-24";

  # Python 2 not supported and not some old Python 3 because MPL doesn't support
  # them properly.
  disabled = !(isPy27);

  # NOTE: This package is different from mpcpy available in PyPI!
  src = /home/jluttine/Workspace/MPCPy;
  # src = fetchFromGitHub {
  #   owner = "lbl-srg";
  #   repo = pname;
  #   rev = "06342e0b91c9679ca7dbda6baf69e2b36cc5d1be";
  #   sha256 = "0hqqskwr69f32s92n6zsliwd6y0dv8syhchh0gjajxblbj3niivb";
  # };

  postPatch = ''
    substituteInPlace mpcpy/utility.py --replace \
      "return MPCPy_path"                        \
      "return \"$out\""
  '';

  # checkInputs = [ pytest glibcLocales ];
  #propagatedBuildInputs = [ matplotlib numpy pandas dateutil pytz scikitlearn sphinx numpydoc tzwhere pymodelica ];

  # checkPhase = ''
  #   LC_ALL=en_US.utf-8 pytest -k 'not test_message_to_parents'
  # '';
  JMODELICA_HOME = "${jmodelica}";
  IPOPT_HOME = "${ipopt}";
  SUNDIALS_HOME = "${sundials}";

  doCheck = false;

  propagatedBuildInputs = [
    numpy
    pandas
    matplotlib
    dateutil
    pytz
    scikitlearn
    tzwhere
    #jmodelica
    JPype1
    openjdk
    pyfmi
    pymodelica
    #pyjmi
    fmilibrary

    shapely
    # SHAPELY NEEDS THIS. MAYBE FIX SHAPELY DERIVATION?
    geos

    # pkgs.gfortran49 <-- this was now added inside the FMU
    gfortran49
    gcc

    jupyter
    ipython
  ];

  postInstall = ''
    cp -r resources $out/
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/lbl-srg/MPCPy;
    description = "Open-source platform for model predictive control (MPC) in buildings";
    license = licenses.bsd3;
    maintainers = with maintainers; [ jluttine ];
  };
}
