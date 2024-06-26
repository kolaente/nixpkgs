{
  lib,
  buildPythonPackage,
  fetchPypi,
  glibcLocales,
  mpmath,

  # Reverse dependency
  sage,
}:

buildPythonPackage rec {
  pname = "sympy";
  version = "1.12";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6/WVyNrD4P3EFSxRh4tJg5bsfzDnqRTWBx5nTUlCD7g=";
  };

  nativeCheckInputs = [ glibcLocales ];

  propagatedBuildInputs = [ mpmath ];

  # tests take ~1h
  doCheck = false;
  pythonImportsCheck = [ "sympy" ];

  preCheck = ''
    export LANG="en_US.UTF-8"
  '';

  passthru.tests = {
    inherit sage;
  };

  meta = with lib; {
    description = "A Python library for symbolic mathematics";
    mainProgram = "isympy";
    homepage = "https://www.sympy.org/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ lovek323 ] ++ teams.sage.members;
  };
}
