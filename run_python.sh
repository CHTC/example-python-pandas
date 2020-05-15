#!/bin/bash

# untar your Python installation. Make sure you are using the right version!
tar -xzf python38.tar.gz
# (optional) if you have a set of packages (created in Part 1), untar them also
tar -xzf packages.tar.gz

# make sure the script will use your Python installation, 
# and the working directory as its home location
export PATH=$PWD/python/bin:$PATH
export PYTHONPATH=$PWD/packages

# run your script, since we will use fruit.csv and vege.csv as input file,
# we put them into the argument
python3 python_example.py fruit.csv vege.csv