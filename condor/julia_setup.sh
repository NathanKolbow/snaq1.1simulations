#!/bin/bash

wget https://julialang-s3.julialang.org/bin/linux/x64/1.9/julia-1.9.3-linux-x86_64.tar.gz
tar -xzf julia-1.9.3-linux-x86_64.tar.gz
export PATH=$PWD/julia-1.9.3/bin:$PATH

