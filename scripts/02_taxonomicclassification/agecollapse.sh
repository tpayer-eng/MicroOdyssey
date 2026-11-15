#!/bin/bash
#SBATCH --job-name=agecollapse
#SBATCH --partition=normal.5h
#SBATCH --time=00:10:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=5G

echo "sourcing bashrc: start"
source ~/.bashrc
echo "sourcing bashrc: end"

echo "environment activation: start"
conda activate rachis-moshpit-2026.7
set -euo pipefail
echo "environment activation: end"

echo "dir definitions: start"
meta_dir=../../data/raw
output_dir=../../output/taxonomic_classification

echo "collapsing feature teable by age timepoint"
qiime feature-table group \
  --i-table $output_dir/bracken-table.qza \
  --p-axis sample \
  --m-metadata-file $meta_dir/metadata_labeled.tsv \
  --m-metadata-column age_label \
  --p-mode sum \
  --o-grouped-table $output_dir/table-by-timepoint.qza

echo "creating barplot"
qiime taxa barplot \
  --i-table $output_dir/table-by-timepoint.qza \
  --i-taxonomy $output_dir/bracken-taxonomy.qza \
  --o-visualization $output_dir/bracken-barplot-bytimepoint.qzv
