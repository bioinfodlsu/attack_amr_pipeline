
# Metagenomic and genomic surveillance of antimicrobial resistance in hospital wastewater (ATTACK-AMR) Analysis Pipeline

The cooperative research project ATTACK-AMR aims to deliver alternative, non-antibiotic therapies to combat antimicrobial resistant (AMR) pathogens. AMR is one of the biggest challenges facing healthcare industries and is on a rapid rise as
a result of the overuse of antibiotics. Replacing antibiotics with alternative products will delay the resistance
and restore the activity of antibiotics that are no longer effective due to resistance.


This serves as a guide to run the analysis pipeline written in two versions, [1] Snakemake and [2] Workflow Description Language (WDL).

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
Download ATTACK-AMR from the online [repository](https://github.com/bioinfodlsu/attack_amr), or using the command line:
```
$ git clone https://github.com/bioinfodlsu/attack_amr
```

## 2. Quickstart Usage Guide

### 2.1. Input
The pipeline requires, at the very least: (1) Metagenomic sequences (sample sequences can be downloaded at [ENA](https://www.ebi.ac.uk/ena/browser/view/PRJEB47975), and (2) reference protein databases for ([Resfinder](https://bitbucket.org/genomicepidemiology/resfinder_db/src/master/), [MGE](https://github.com/KatariinaParnanen/MobileGeneticElementDatabase)).
These and other input parameters are specified via a YAML-format config file -- config.yaml is provided in the config folder. 

### 2.2. Running the pipeline
After constructing a config.yaml file and with the snakemake conda environment activated, you can call the pipeline from the top-level directory of ATTACK-AMR:
```
$ cd attack_amr 
$ snakemake --use-conda --cores all
```

### 2.3. Ouput
Outputs are stored the top-level directory of ATTACK-AMR.



## Installation for Workflow Description Language

If working on a non-Linux machine, the following installation guidelines will work using WSL software in your local Windows machine.

Follow installation guidelines at https://miniwdl.readthedocs.io/en/latest/getting_started.html.

### Install miniWDL 

#### via PyPI
```bash
  pip3 install miniwdl
```
#### via Conda
```bash
  conda install -c conda-forge miniwdl
```
Then open a command prompt and try, 
```bash
  miniwdl run_self_test
```
…to test the installation with WDL's built in workflow. This should end with miniwdl run_self_test OK.

#### If there is an error prompt due to docker engine, follow these series of steps

1. Update the **apt** package index.
```bash
   sudo apt-get update
```
2. Install docker engine.
```bash
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
3. Verify that the Docker Engine installation is successful by running the hello-world image.
```bash
   sudo docker run hello-world
```
4. Activate **docker daemon**. 
```bash
   sudo dockerd
```
5. Run the miniWDL test script on a separate command prompt.
```bash
   miniwdl run_self_test
```
### Run WDL Script via Command Prompt
You can choose to run the miniWDL through your command prompt.

1. Check your WDL Script for any errors.
```bash
   miniwdl check main.wdl --no-shellcheck
```
2. If no errors are detected, run your pipeline.
***Note: Place all your input files in one json file.***
```bash
   miniwdl run main.wdl --input inputs.json
```

### Alternative: Running it via Jupyter
These are the steps to run it via **Jupyter Notebook**. 

1. Install Jupyter Notebook. 
```bash
   pip install jupyterlab
```
2. Run Jupyter Notebook.
```bash
   jupyter-lab
```
3. Run the WDL Script via Jupyter's terminal. 
```bash
   miniwdl check main.wdl --no-shellcheck
   miniwdl run main.wdl --input inputs.json
```
