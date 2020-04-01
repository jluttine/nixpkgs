{ lib, buildPythonPackage, fetchFromGitHub, notebook, psutil, pytest, mock, nodejs }:

buildPythonPackage rec {

  pname = "jupyterlab-git";
  #version = "0.5.0";
  version = "0.4.4";

  # PyPI package doesn't contain Node.js part of the extension, so let's use
  # GitHub
  # src = fetchPypi {
  #   inherit pname version;
  #   sha256 = "1zzbi9wh7q4lr1srnvjfir4wply874m0d0ncmib6ii5i31j1nasr";
  # };
  #
  src = fetchFromGitHub {
    owner = "jupyterlab";
    repo = pname;
    rev = "v${version}";
    sha256 = "0iqalym2yklwcpwd3pjfyv7h00q2qz8gy6jf9lbq55xmqhq103p7";
  };

  buildInputs = [ nodejs ];
  propagatedBuildInputs = [ notebook psutil ];
  checkInputs = [ pytest mock ];

  preBuild = ''
    npm install
  '';

  checkPhase = ''
    pytest tests
  '';

  meta = with lib; {
    # description = "Jupyter lab environment notebook server extension.";
    # license = with licenses; [ bsd3 ];
    # homepage = "http://jupyter.org/";
    # maintainers = with maintainers; [ zimbatm costrouc ];
  };

}
