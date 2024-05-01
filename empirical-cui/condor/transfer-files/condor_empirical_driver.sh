#!/bin/bash
set -e

echo "Entering bash script"

# Setup Julia
echo "Unpacking Julia"
tar -xzf julia-1.9.3-linux-x86_64.tar.gz
echo "Unpacking project"
tar -xzf snaq2-proj.tar.gz
export PATH=$PWD/julia-1.9.3/bin:$PATH
export JULIA_DEPOT_PATH=$PWD/snaq2-proj/

# Argument
num_hybrids=$1

# Run the script
echo "Running Julia script from bash"
julia --project=snaq2-proj/ -p15 -t16 ./script.jl ${num_hybrids}
