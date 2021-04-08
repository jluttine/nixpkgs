{ lib, buildPythonPackage, fetchPypi, ipywidgets, jupyter-packaging, matplotlib }:

buildPythonPackage rec {
  pname = "ipympl";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "18dhdm6vqbl7h5hgcwnb2r9i94616zwbnvdq3fslz7fbv1bg7wgh";
  };

  buildInputs = [ jupyter-packaging ];

  propagatedBuildInputs = [ ipywidgets matplotlib ];

  # There are no unit tests in repository
  doCheck = false;
  pythonImportsCheck = [ "ipympl" "ipympl.backend_nbagg" ];

  meta = with lib; {
    description = "Matplotlib Jupyter Extension";
    homepage = "https://github.com/matplotlib/jupyter-matplotlib";
    maintainers = with maintainers; [ jluttine ];
    license = licenses.bsd3;
  };
}
