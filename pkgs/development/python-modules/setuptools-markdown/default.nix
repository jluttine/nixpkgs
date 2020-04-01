{ lib, fetchPypi, buildPythonPackage, pypandoc }:

buildPythonPackage rec {
  pname = "setuptools-markdown";
  version = "0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "123445677i8zsvmb2iw20qrmkjkyh4g5r5y2dqc616vyxka5q8hp";
  };

  #checkInputs = [ pytest setuptools-markdown ];
  propagatedBuildInputs = [ pypandoc ];

  meta = {
    description = "";
    homepage = "";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
