#!/bin/bash

# Install Julia
tar -xzf julia-1.9.3-linux-x86_64.tar.gz
export PATH=$PWD/julia-1.9.3/bin:$PATH

# Navigate to the relevant folder
cd /mnt/ws/home/nkolbow/snaq2/pipelines/

# Run stuff
echo "Running stuff"
echo $1
echo $2
echo $3
echo $4
echo $5