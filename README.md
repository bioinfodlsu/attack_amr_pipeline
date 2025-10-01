
# Investigating the resistome, bacterial composition, and mobilome in hospital wastewaters in Metro Manila using a shotgun metagenomics approach

This study provides an initial report of antibiotic resistance genes (ARGs), antibiotic resistant bacteria (ARBs), and mobile genetic elements (MGEs) in influent hospital wastewater (HWW) from three hospitals using shotgun metagenomic sequencing.


This serves as a guide to run the analysis pipeline written in Snakemake.

## Installation for Snakemake
This Snakemake pipeline requires the package manager **Conda** and the workflow management system **Snakemake**.
Additional dependencies not handled by Snakemake are described in Section 1.3.

### 1.1. Install Miniconda 
```
$ curl -sL \
  "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" > \
  "Miniconda3.sh"
$ bash Miniconda3.sh
$ conda update conda
$ rm Miniconda3.sh
$ conda install wget
```

### 1.2. Install Mamba 
```
$ conda config --add channels conda-forge
$ conda update -n base --all
$ conda install -n base mamba
```

### 1.3. Install Snakemake
```
$ mamba create -c conda-forge -c bioconda -n snakemake snakemake
```
This creates an isolated enviroment containing the latest Snakemake. To activate it:
```
$ conda activate snakemake
```
To test snakemake:
```
$ snakemake --help
```

### 1.4. Install Additional Dependencies
Install git and gawk. We require gawk to process the filtering stage of our databases.
```
$ mamba install git
$ mamba install gawk
```

### 1.5. Download the pipeline
Download ATTACK-AMR from the online [repository](https://github.com/bioinfodlsu/attack_amr_pipeline), or using the command line:
```
$ git clone https://github.com/bioinfodlsu/attack_amr_pipeline
```

## 2. Quickstart Usage Guide

### 2.1. Input
The pipeline requires, at the very least: (1) Metagenomic sequences (sample sequences can be downloaded [here](*tentative*)), and (2) reference databases ([CARD](https://card.mcmaster.ca/latest/data), [Kraken2](https://benlangmead.github.io/aws-indexes/k2), [ISFinder](https://isfinder.biotoul.fr/), [PlasmidFinder](https://bitbucket.org/genomicepidemiology/workspace/projects/DB), and [INTEGRALL](http://integrall.bio.ua.pt/)).


Note: For CARD, only the **nucleotide_fasta_protein_homolog_model.fasta** file was used. For Kraken, the Standard-16 Database was used for taxonomic analysis. CARD and MGE fasta files were renamed as **card.fasta**,  **ISFinder.fasta**, **PlasmidFinder.fasta**, and **integrall.fasta** respectively.


All downloaded databases should be placed in the following directories:
1. Metagenomic Sequences: **~/data**
2. CARD: **~/card_db**
3. Kraken: **~/kraken2_db**
4. ISFinder: **~/ISFinder_db**
4. PlasmidFinder: **~/PlasmidFinder_db**
4. INTEGRALL: **~/integrall_db**
 

### 2.2. Running the pipeline
With the snakemake conda environment activated, you can call the pipeline from the top-level directory of ATTACK-AMR:
```
$ cd attack_amr_pipeline
$ snakemake --use-conda --cores all
```
In case of errors encountered relating to the use of conda environments, please use the following command:
```
$ snakemake --use-conda --cores all --conda-frontend conda

```

### 2.3. Ouput
Outputs are stored the top-level directory of ATTACK-AMR. The following outputs should be present. 

ARG (CARD):
1. card_db/card_length.txt
2. card_out/ARG_genemat.txt

Taxonomic (Kraken2):
1. kreport2mpa_norm/merged_metakraken_abundance_table.txt

MGE
1. ISFinder_db/IS_length.txt
2. ISFinder_out/ISFinder_genemat.txt
3. PlasmidFinder_db/PlasmidFinder_length.txt
4. PlasmidFinder_out/PlasmidFinder_genemat.txt
5. integrall_db/integrall_length.txt
6. integrall_out/integrall_genemat.txt


Before running the R analysis notebooks, it is ideal to place all of the above output files into one directory (the same directory where the R analysis notebooks are at).

### 2.4 Running the R analysis notebooks
Before running the notebooks in this repository, ensure you have prepared the following files for your samples:

1. **`metadata.csv`** – metadata describing your samples  
2. **`bases_number.csv`** – number of bases in your samples  
3. **`card_drug_class.txt`** – CARD drug class information with columns, Gene and Class retrieved from [CARD website](https://card.mcmaster.ca/)

Analysis scripts are made each for ARG analysis, Taxonomic analysis and MGE analysis. These are located in the notebooks folder in the repository. The notebooks are written in R used to produced data visualizations.

Note that some library dependencies may need to be first installed through this command:

```
install.packages('<insert name of library>')
```





