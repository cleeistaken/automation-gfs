#! /bin/bash

echo "Exporting SETUPTOOLS_USE_DISTUTILS"
export SETUPTOOLS_USE_DISTUTILS=stdlib

echo "Creating and entering into pipenv"
pipenv install --python `which python3`

echo "Staring pipenv shell"
pipenv shell
