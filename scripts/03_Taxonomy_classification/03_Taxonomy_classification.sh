#!/bin/bash
#SBATCH --job-name=03_Taxonomy_classification
#SBATCH --mail-type=END
#SBATCH --partition=bigmem.120h
#SBATCH --time=5-00:00:00
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=20G

echo "sourcing bashrc: start"
source ~/.bashrc
echo "sourcing bashrc: end"

echo "environment activation: start"
conda activate rachis-moshpit-2026.7
echo "environment activation: end"

echo "dir definitions: start"
data_dir="../../data/raw/"
output_dir="../../output/taxonomic_classification"
mkdir -p $output_dir
echo "dir definitions: end"

echo "fetch database: start $(date)"
mosh annotate build-kraken-db \
    --p-collection pluspf \
    --o-kraken2-db $output_dir/kraken2-db.qza \
    --o-bracken-db $output_dir/bracken-db.qza \
    --verbose
echo "fetch database: end $(date)"

echo "classify reads to taxonomies: start $(date)"
mosh annotate classify-kraken2 \
    --i-seqs $data_dir/reads.qza \
    --i-db $output_dir/kraken2-db.qza \
    --p-threads 6 \
    --p-memory-mapping \
    --o-reports $output_dir/kraken2-reports-reads.qza \
    --o-outputs $output_dir/kraken2-hits-reads.qza \
    --parallel-config $output_dir/parallel.config.toml \
    --verbose
echo "classify reads to taxonomies: end $(date)"

echo "correct read counts to account for the genome size and database composition: start $(date)"
mosh annotate estimate-bracken \
    --i-kraken2-reports $output_dir/kraken2-reports-reads.qza \
    --i-db $output_dir/bracken-db.qza \
    --p-read-len 150 \
    --o-reports $output_dir/bracken-reports.qza \
    --o-taxonomy $output_dir/bracken-taxonomy.qza \
    --o-table $output_dir/bracken-table.qza \
    --verbose
echo "correct read counts to account for the genome size and database composition: end $(date)"    
    
echo "store visualization: start $(date)"    
mosh taxa barplot \
    --i-table $output_dir/bracken-table.qza \
    --i-taxonomy $output_dir/bracken-taxonomy.qza \
    --o-visualization $output_dir/bracken-barplot.qzv \
    --verbose
echo "store visualization: end $(date)"



echo "TAXONOMIC CLASSIFICATION FINISHED $(date)"