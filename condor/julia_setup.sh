#!/bin/bash

# Install Julia
tar -xzf julia-1.9.3-linux-x86_64.tar.gz
export PATH=$PWD/julia-1.9.3/bin:$PATH

# Install dendropy for gtee
pip3 install dendropy --user

# Install relevant Julia packages
julia julia-package-install.jl

# Navigate to the relevant folder
cd /mnt/ws/home/nkolbow/snaq2/pipelines/

# Run stuff
# - $1: network newick (already quoted in the submit file)
# - $2: results file
# - $3: number of gene trees
# - $4: number of processors
./run-one.sh $1 "$2" $3 $4