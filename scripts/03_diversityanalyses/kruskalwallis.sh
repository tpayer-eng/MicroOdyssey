#!/bin/bash
#SBATCH --job-name=kruskalwallis
#SBATCH --mail-type=END
#SBATCH --partition=normal.4h
#SBATCH --time=01:00:00
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
data_dir="../../output/expl_diversity/richnessbaseddepth/core-metrics-results"
metadata_dir="../../output/expl_diversity/"
output_dir="../../output/stat_diversity/kruskallwallis"
mkdir -p $output_dir
echo "dir definitions: end"

echo "compute significances and correlations: start $(date)"
python subset_metadata.py $metadata_dir/metadata_numage.tsv $output_dir/metadata_subset.tsv \
  delivery_mode host_sex diet_milk age_months seq_depth

for vec in shannon observed_features evenness; do
  echo "$vec: start $(date)"

  qiime diversity alpha-group-significance \
    --i-alpha-diversity $data_dir/${vec}_vector.qza \
    --m-metadata-file $output_dir/metadata_subset.tsv \
    --o-visualization $output_dir/${vec}-group-significance.qzv

  qiime diversity alpha-correlation \
    --i-alpha-diversity $data_dir/${vec}_vector.qza \
    --m-metadata-file $output_dir/metadata_subset.tsv \
    --p-method spearman \
    --o-visualization $output_dir/${vec}-correlation.qzv

  echo "$vec: end $(date)"
done
echo "compute significances and correlations: start $(date)"

