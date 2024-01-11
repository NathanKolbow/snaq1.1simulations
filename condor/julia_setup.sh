#!/bin/bash

# Unpack and install julia
tar -xzf julia-1.9.3-linux-x86_64.tar.gz
export PATH=$PWD/julia-1.9.3/bin:$PATH

# Install julia packages
julia julia-package-install.jl

# Install dendropy
pip3 install dendropy --user

# Run stuff
# - $1: network newick (already quoted in the submit file)
# - $2: results file
# - $3: number of gene trees
# - $4: number of processors
# - $5: ILS
# - $6: replicate
./run-one.sh $1 "$2" $3 $4 $5 $6