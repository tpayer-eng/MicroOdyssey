#!/bin/bash
#SBATCH --job-name=permanova
#SBATCH --mail-type=END
#SBATCH --partition=normal.4h
#SBATCH --time=00:30:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=5G

echo "sourcing bashrc: start"
source ~/.bashrc
echo "sourcing bashrc: end"

echo "environment activation: start"
conda activate /cluster/scratch/tpayer/envs/rachis-qiime2-2026.7
set -euo pipefail
echo "environment activation: end"

echo "dir definitions: start"
distmat_dir="../../output/expl_diversity/richnessbaseddepth/core-metrics-results"
metadata_dir="../../output/expl_diversity"
output_dir="../../output/stat_diversity/permanova"
mkdir -p $output_dir
echo "dir definitions: end"


echo "permanova and permdisp: start $(date)"
columns=(delivery_mode host_age diet_milk)

for col in "${columns[@]}"; do
  for method in permanova permdisp; do
    qiime diversity beta-group-significance \
      --i-distance-matrix $distmat_dir/bray_curtis_distance_matrix.qza \
      --m-metadata-file $metadata_dir/metadata_numage.tsv \
      --m-metadata-column $col \
      --p-method $method \
      --p-permutations 999 \
      --o-visualization $output_dir/braycurtis_${method}_${col}.qzv \
      || echo "FAILED $method for $col, continuing"
  done
done
echo "permanova and permdisp: end $(date)"

echo "DONE"
