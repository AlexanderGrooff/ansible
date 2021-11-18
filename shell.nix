{ pkgs ? import <nixpkgs> {}}:

let
  pyEnv = pkgs.python39.withPackages(ps: with ps; [
    # Venv packages
    pip
    pre-commit
    setuptools
    virtualenv
    wheel
  ]);
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      pyEnv
    ];

    shellHook = ''
      VENV_DIR=$(pwd)/.venv
      python -m venv $VENV_DIR
      . $VENV_DIR/bin/activate
      export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
    '';
  }
