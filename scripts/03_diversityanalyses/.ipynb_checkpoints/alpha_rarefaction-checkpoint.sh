#!/bin/bash
#SBATCH --job-name=rarefaction
#SBATCH --mail-type=END
#SBATCH --partition=normal.4h
#SBATCH --time=03:00:00
#SBATCH --cpus-per-task=3
#SBATCH --mem-per-cpu=10G

echo "sourcing bashrc: start"
source ~/.bashrc
echo "sourcing bashrc: end"

echo "environment activation: start"
conda activate /cluster/scratch/tpayer/envs/rachis-qiime2-2026.7
set -euo pipefail
echo "environment activation: end"

echo "dir definitions: start"
data_dir="../../data/raw/"
taxonomy_dir="../../output/taxonomic_classification"
output_dir="../../output/alpha_diversity"
mkdir -p $output_dir
echo "dir definitions: end"

echo "alpha rarefaction: start $(date)"
echo "(note: max depth was obtained from feature table summary (s. 01_expl_dataanalysis)"
qiime diversity alpha-rarefaction \
  --i-table $taxonomy_dir/bracken-table.qza \
  --p-iterations 5 \
  --p-max-depth 18000000 \
  --m-metadata-file $output_dir/metadata_numage.tsv \
  --o-visualization $output_dir/alpha-rarefaction.qzv
echo "alpha rarefaction: end $(date)"



