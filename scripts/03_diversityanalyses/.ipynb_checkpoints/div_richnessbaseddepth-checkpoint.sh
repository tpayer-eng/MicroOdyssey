#!/bin/bash
#SBATCH --job-name=expl_div_richnessbaseddepth
#SBATCH --mail-type=END
#SBATCH --partition=normal.4h
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=15G

echo "sourcing bashrc: start"
source ~/.bashrc
echo "sourcing bashrc: end"

echo "environment activation: start"
conda activate /cluster/scratch/tpayer/envs/rachis-qiime2-2026.7
set -euo pipefail
echo "environment activation: end"

echo "dir definitions: start"
taxonomy_dir="../../output/taxonomic_classification"
output_dir="../../output/expl_diversity/richnessbaseddepth"
mkdir -p $output_dir
echo "dir definitions: end"

echo "diversity core metrics computation: start $(date)"
qiime diversity core-metrics \
  --i-table $taxonomy_dir/bracken-table.qza \
  --p-sampling-depth 8500000 \
  --m-metadata-file $output_dir/../../../data/raw/metadata.tsv \
  --p-n-jobs 4 \
  --output-dir $output_dir/core-metrics-results
echo "diversity core metrics computation: end $(date)"



