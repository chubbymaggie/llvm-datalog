#!/usr/bin/env python

import os
from distutils import sysconfig
from distutils.core import setup
from glob import glob
from os import path

# Get python site-packages directory. This will be correctly resolved
# even in the case we're inside a virtual environment
site_packages_path = sysconfig.get_python_lib()


setup(
    name='Copper',
    version='1.0',
    author='George Balatsouras',
    author_email='gbalats@gmail.com',
    description=(
        "A static analysis framework that uses the LogicBlox "
        "Datalog engine for analyzing LLVM bitcode."
    ),
    keywords="LLVM datalog static analysis",
    license="MIT",
    url='https://github.com/plast-lab/llvm-datalog',
    classifiers=[
        "Development Status :: 3 - Alpha",
        "License :: OSI Approved :: MIT License",
        "Operating System :: POSIX :: Linux",
        "Topic :: Utilities",
    ],
    py_modules=['__main__'],
    # Packages to be included
    packages=[
        'blox', 'copper', 'copper.cli', 'copper.config',
        'copper.runtime', 'resources', 'utils'
    ],
    # Additional package data
    package_data={
        'resources' : [
            'logic/*.lbb',
            'logic/*.lbp',
            'logic/*.project',
            'logic/*/checksum',
        ],
    },
    # Additional data outside any python packages
    data_files=[
        # Add dynamic libraries
        (site_packages_path, glob(path.join('lib', '*.so'))),
    ],
    # Source code directory
    package_dir= {'': 'src/main'},
)
