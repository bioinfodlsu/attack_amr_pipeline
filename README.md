
# Metagenomic and genomic surveillance of antimicrobial resistance in hospital wastewater (ATTACK-AMR) Analysis Pipeline

The cooperative research project ATTACK-AMR aims to deliver alternative, non-antibiotic therapies to combat antimicrobial resistant (AMR) pathogens. AMR is one of the biggest challenges facing healthcare industries and is on a rapid rise as
a result of the overuse of antibiotics. Replacing antibiotics with alternative products will delay the resistance
and restore the activity of antibiotics that are no longer effective due to resistance.


This serves as a guide to run the analysis pipeline written in the Workflow Description Language (WDL).


## Installation

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
   miniwdl check file.wdl --no-shellcheck
   miniwdl run main.wdl --input inputs.json
```
