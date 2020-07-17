{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "radicale-storage-decsync";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1234527ce241a0113abf217fbaf41ac25e04f5a01f9ed606610f2f1f2d82d34f";
  };

  # checkInputs = [ pytest nose glibcLocales ];
  # propagatedBuildInputs = [ numpy scipy matplotlib h5py ];

  # checkPhase = ''
  #   LC_ALL=en_US.utf-8 pytest -k 'not test_message_to_parents'
  # '';

  # meta = with stdenv.lib; {
  #   homepage = "http://www.bayespy.org";
  #   description = "Variational Bayesian inference tools for Python";
  #   license = licenses.mit;
  #   maintainers = with maintainers; [ jluttine ];
  # };
}
