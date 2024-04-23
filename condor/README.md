# HTCondor Execution Overview <!-- omit from toc -->

This folder contains the elements needed for executing computations via HTCondor.

## Table of contents <!-- omit from toc -->

- [Directory structure](#directory-structure)
- [How to execute simulations](#how-to-execute-simulations)

## Directory structure

> condor/julia-projects/
> - `julia` packages must be compiled into projects, zipped, and transferred into HT Condor jobs for best performance ([info here](https://chtc.cs.wisc.edu/uw-research-computing/julia-jobs)). This directory contains everything related to that.

> condor/logs/
> - Log files from all HTCondor runs.

> condor/scripts/
> - Contains all scripts utilized throughout our jobs.
> - Does NOT contain any computation-related `julia` scripts; those can be found in `pipelines/*.jl`.

> condor/submits/
> - Submit files used to submit jobs to HTCondor.

> condor/transfer-files/
> - Miscellaneous files that are transferred into HTCondor jobs.

## How to execute simulations

We outline each step of how the simulation study itself is supposed to flow along with how to do that step via HT Condor.

1. Simulate estimated gene trees for each unique `combo` of: [network topology, ILS level, replicate number]
   - `cd condor/submits/`
   - `condor_submit treefile_generation.sub`
2. Estimate a species network for each `combo` with SNaQ 1.0
   - `cd condor/submits/`
   - `condor_submit snaq1.sub`
3. For each `combo`, estimate a species network with SNaQ 2.0 with the following parameters: probQR in [0, 0.5, 1] X propQuartets in [1, 0.9, 0.7]
   - `cd condor/submits/`
   - `condor_submit snaq2.sub`