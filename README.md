# ABC model with Snakemake

This fork is for adding convenience to the workflow of ABC model using Snakemake (https://snakemake.github.io/).

## Prerequisite

A [Conda](https://docs.conda.io/en/latest/) package manager (Python3) is required. And in a Conda-based Python distribution, Mamba (https://github.com/mamba-org/mamba) is recommended.

Mamba will be installed with

```
conda install -c conda-forge mamba
```

Installing Snakemake, samtools, and bedtools via

```
mamba env create -f environment.yaml
```

# Activity by Contact Model of Enhancer-Gene Specificity

The Activity-by-Contact (ABC) model predicts which enhancers regulate which genes on a cell type specific basis. This repository contains the code needed to run the ABC model as well as small sample data files, example commands, and some general tips and suggestions. We provide a brief description of the model below, see Fulco, Nasser et al [1] for a full description.

v0.2 is the recommended version for the majority of users. There are some minor methodological differences between v0.2 and the model as described in [1]. These differences are related to Hi-C data processing and were implemented to improve the speed and scalability of the codebase. As such ABC scores computing using v0.2 will not exactly match those published in [1], although they will be very close. The codebase used to generate the results in [1] is available in the NG2019 branch of this repository. The NG2019 branch is no longer maintained.

If you use the ABC model in published research, please cite:

[1] Fulco CP, Nasser J, Jones TR, Munson G, Bergman DT, Subramanian V, Grossman SR, Anyoha R, Doughty BR, Patwardhan TA, Nguyen TH, Kane M, Perez EM, Durand NC, Lareau CA, Stamenova EK, Aiden EL, Lander ES & Engreitz JM. Activity-by-contact model of enhancer–promoter regulation from thousands of CRISPR perturbations. Nat. Genet. 51, 1664–1669 (2019). https://www.nature.com/articles/s41588-019-0538-0


## Requirements
For each cell-type, the inputs to the ABC model are:

 * Required Inputs
 	* bam file for Dnase-Seq or ATAC-Seq (indexed and sorted)
 	* bam file for H3K27ac ChIP-Seq (indexed and sorted)
 * Optional Inputs
 	* Hi-C data (see the Hi-C section below)
 	* A measure of gene expression (see gene expression section)

In addition the following (non-cell-type specific) genome annotation files are required

 * bed file containing gene annotations (may change across cell types if using cell-type specific TSS's)
 * bed file containing chromosome annotations
