#!/bin/bash
#SBATCH --job-name=03_Taxonomy_classification
#SBATCH --mail-type=END
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=20G

echo "sourcing bashrc: start"
source ~/.bashrc
echo "sourcing bashrc: end"

echo "environment activation: start"
conda activate rachis-moshpit-2026.7
echo "environment activation: end"

echo "dir definitions: start"
# define data dir
data_dir="../data/raw"

output_dir_MAG="../output/03_MAGbased_Taxonomyclassification"
output_dir_read="../output/03_readbased_Taxonomyclassification"

mkdir -p $output_dir_MAG
mkdir -p $output_dir_read
echo "dif definitions: end"

echo "METHOD 1: MAG-BASED CLASSIFICATION"
...