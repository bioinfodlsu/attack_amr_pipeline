
# Metagenomic and genomic surveillance of antimicrobial resistance in hospital wastewater (ATTACK-AMR) Analysis Pipeline

The cooperative research project ATTACK-AMR aims to deliver alternative, non-antibiotic therapies to combat antimicrobial resistant (AMR) pathogens. AMR is one of the biggest challenges facing healthcare industries and is on a rapid rise as
a result of the overuse of antibiotics. Replacing antibiotics with alternative products will delay the resistance
and restore the activity of antibiotics that are no longer effective due to resistance.


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
The pipeline requires, at the very least: (1) Metagenomic sequences (sample sequences can be downloaded at (tentative)), and (2) reference protein databases for ([CARD](https://card.mcmaster.ca/latest/data), [Kraken] (https://benlangmead.github.io/aws-indexes/k2) [MGE](https://github.com/KatariinaParnanen/MobileGeneticElementDatabase)). 

Note: For CARD, only the **nucleotide_fasta_protein_homolog_model.fasta** file was used. For Kraken, the Standard-16 Database was used for taxonomic analysis. CARD and MGE fasta files were renames as **card.fasta** and **MGE.fasta** respectively.

For Metaphlan, running 
```
$ metaphlan --install --bowtie2db /attack_amr_pipeline/metaphlan 
```
should download the latest database for you. It is a prerequisite to have Metaphlan installed locally using 
```
$ conda install -c bioconda metaphlan
```

All downloaded databases should be placed in the following directories:
1. Metagenomic Sequences: **~/data**
2. CARD: **~/card_db**
3. Kraken: **~/kraken2_db**
4. Metaphlan: **~/metaphlan**
5. MGE: **~/MGE_db**


These and other input parameters are specified via a YAML-format config file -- config.yaml is provided in the config folder. 

### 2.2. Running the pipeline
After constructing a config.yaml file and with the snakemake conda environment activated, you can call the pipeline from the top-level directory of ATTACK-AMR:
```
$ cd attack_amr_pipeline
$ snakemake --use-conda --cores all
```

### 2.3. Ouput
Outputs are stored the top-level directory of ATTACK-AMR. The following outputs should be present. 

ARG (CARD):
1. card_db/card_length.txt
2. card_out/ARG_genemat.txt
3. metaxa2/metaxa_genus.txt

Taxonomic (Kraken and Metaphlan):
1. kreport2mpa_norm/merged_metakraken_abundance_table.txt
2. metaphlan/merged_abundance_table.txt

MGE
1. MGE_db/MGE_length.txt
2. MGE_out/MGE_genemat.txt

Before running the R analysis notebooks, it is ideal to place all of the above output files into one directory (the same directory where the R analysis notebooks are at).

### 2.4 Running the R analysis notebooks

First download the metadata (metadata.csv) and CARD drug class information (card_drug_class.txt) before running the notebooks located in the repository.

Analysis scripts are made each for ARG analysis, Taxonomic analysis and MGE analysis. These are located in the notebooks folder in the repository. The notebooks are written in R used to produced data visualizations which include stacked bar plots, PCA plots and box plots for diversity analysis.

Note that some library dependencies may need to be first installed through this command:

```
install.packages('<insert name of library>')
```





