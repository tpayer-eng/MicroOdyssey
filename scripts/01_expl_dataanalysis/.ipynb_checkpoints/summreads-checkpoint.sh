#!/bin/bash
#SBATCH --job-name=summreads
#SBATCH --mail-type=END
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=16G

echo "sourcing bashrc: start"
source ~/.bashrc
echo "sourcing bashrc: end"

echo "environment activation: start"
conda activate rachis-moshpit-2026.7
echo "environment activation: end"

echo "directory definition: start"
data_dir="../../data/raw"
output_dir="../../output/exploratory_dataanalysis"
mkdir -p $output_dir
echo "directory definition: end"

echo "summarizing reads: start $(date)"
qiime demux summarize \
	--i-data $data_dir/reads.qza \
	--o-visualization $output_dir/visualization.qzv
echo "summarizing reads: end $(date)"
