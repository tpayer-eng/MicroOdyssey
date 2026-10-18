#!/bin/bash
#SBATCH --job-name=full_02_contig_assembly
#SBATCH --partition=bigmem.120h
#SBATCH --mail-type=END
#SBATCH --time=7-00:00:00
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
data_dir="../../../data/raw/"
output_dir="../../../output/MAG_assembly/full/"
mkdir -p $output_dir
echo "dir definitions: end"



echo "assembling reads into contigs: start $(date)"
qiime assembly assemble-megahit \
    --i-reads  $data_dir/reads.qza \
    --p-presets meta-large \
    --p-num-cpu-threads 6 \
    --o-contigs $output_dir/contigs.qza
echo "assembling reads into contigs: end $(date)"

    

