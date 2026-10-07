#!/bin/bash
#SBATCH --job-name=MAG_assembly
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4

jupyter nbconvert --to notebook --execute 02_MAG_assembly.ipynb --output 02_MAG_assembly_output.ipynb