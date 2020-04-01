{ lib, buildPythonPackage, fetchPypi, jupyterhub, bash }:

buildPythonPackage rec {
  pname = "jupyterhub-systemdspawner";
  version = "0.11";

  # NOTE: PyPI release tarball doesn't contain tests
  src = fetchPypi {
    inherit pname version;
    sha256 = "0z4sy0k413w1z7ywrijfk2p01ym83k4nlnbkn3vzkzpgqnc5r5rl";
  };

  postPatch = ''
    substituteInPlace systemdspawner/systemd.py --replace "/bin/bash" "${bash}/bin/bash"
    substituteInPlace systemdspawner/systemdspawner.py --replace "/bin/bash" "${bash}/bin/bash"
  '';

  propagatedBuildInputs = [jupyterhub];

  # meta = with lib; {
  #   description = "Serves multiple Jupyter notebook instances";
  #   homepage = http://jupyter.org/;
  #   license = licenses.bsd3;
  #   maintainers = with maintainers; [ ixxie cstrahan ];
  # };
}
