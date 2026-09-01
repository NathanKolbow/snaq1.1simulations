# SNaQ 1.1 Simulations and Empirical Analysis

<img src="https://github.com/JuliaPhylo/SNaQ.jl/raw/main/docs/src/snaq.png" align=right title="SNaQ logo" width=262.5 height=111 style="padding-left: 20px"/>

Simulation study and empirical analysis evaluating computational improvements made in [SNaQ.jl](https://github.com/JuliaPhylo/SNaQ.jl) version 1.1, a Julia package for phylogenetic network inference using composite likelihood. This version introduces significant scalability improvements including parallelized quartet calculations, weighted quartet selection, and probabilistic network search, achieving up to 400% runtime improvements with maintained accuracy.

## Replication Instructions

Given the breadth of parameters tested in these simulations and the computational intensity of each simulation individually, it is necessary to perform this study on a high throughput computing cluster. For this purpose, we utilize HT Condor. You will find that many of the scripts in this repository are specifically structured to work in a Condor environment and will not work properly outside of such an environment. See `condor/README.md` for replication instructions on a Condor cluster.

## Study Overview

This repository contains the complete computational pipeline for:

- **Simulation Study**: Network inference performance and runtime analysis with networks consisting of either 10 or 20 taxa and either 1 or 3 hybrid nodes.
- **Empirical Analysis**: Application to *Xiphophorus* phylogenomic data from [Cui et al. 2013](https://doi.org/10.1111/evo.12099)
- **Performance Evaluation**: Runtime and accuracy comparisons between SNaQ.jl versions 1.0 and 1.1

## Repository Structure

- **`condor/`** - HTCondor job submission and execution scripts
- **`data/`** - Original networks, simulation outputs, and figures
- **`empirical-cui/`** - Empirical analysis using Cui et al. 2013 *Xiphophorus* dataset
- **`pipelines/`** - Core Julia simulation and analysis scripts
- **`results/`** - Consolidated results from all simulation analyses
- **`scripts/`** - Utility scripts for data processing
- **`software/`** - External tools (IQ-TREE, Seq-Gen)

## Citing

For the theory and methodology used in the SNaQ method please cite

- Claudia Sol&iacute;s-Lemus and C&eacute;cile An&eacute; (2016).
  Inferring Phylogenetic Networks with Maximum Pseudolikelihood under Incomplete Lineage Sorting.
  [PLoS Genet](http://journals.plos.org/plosgenetics/article?id=10.1371/journal.pgen.1005896)
  12(3):e1005896.
  [doi:10.1371/journal.pgen.1005896](https://doi.org/10.1371/journal.pgen.1005896)

When citing the use of SNaQ.jl version 1.1 specifically please cite

- Nathan Kolbow, Sungsik Kong, Tyler Chafin, C&eacute;cile An&eacute; and Claudia Sol&iacute;s-Lemus (2026).
  SNaQ.jl: Improved scalability for level-1 phylogenetic network inference.
  [Bioinformatics]([https://doi.org/10.1093/bioinformatics/btag289](https://academic.oup.com/bioinformatics/article/42/6/btag289/8675975))
  42(6):btag289.
  [doi:10.1093/bioinformatics/btag289](https://doi.org/10.1093/bioinformatics/btag289)

For the PhyloNetworks package, please cite:
- Claudia Solís-Lemus, Paul Bastide and Cécile Ané (2017). 
  PhyloNetworks: a package for phylogenetic networks. Molecular Biology and Evolution 34(12):3292–3298. [doi:10.1093/molbev/msx235](https://academic.oup.com/mbe/article/34/12/3292/4103410)

See [`CITATION.bib`](CITATION.bib) for BibTeX citations.
