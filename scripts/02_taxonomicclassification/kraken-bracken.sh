#!/bin/bash
#SBATCH --job-name=02_taxclass
#SBATCH --partition=normal.120h
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=16G
#SBATCH --tmp=40G
#SBATCH --mail-type=END,FAIL
#SBATCH --output=logs/%x_%j.out


echo "setup: start $(date)"
source ~/.bashrc
conda activate rachis-moshpit-2026.7
set -euo pipefail

READS="../../data/raw/reads.qza"             
META="../../data/raw/metadata.tsv"
OUT="../../output/02_taxonomicclassification"
DB_COLLECTION=pluspf16     
READ_LEN=150               
THREADS=${SLURM_CPUS_PER_TASK:-12}
export TMPDIR=${SLURM_TMPDIR:-/tmp}
mkdir -p "$OUT" logs
echo "setup: end $(date)"



echo "1. Kraken2 + Bracken DB: $(date)"
if [ ! -f "$OUT/kraken2-db.qza" ] || [ ! -f "$OUT/bracken-db.qza" ]; then
  mosh database fetch-kraken-db \
    --p-collection "$DB_COLLECTION" \
    --o-kraken2-db "$OUT/kraken2-db.qza" \
    --o-bracken-db "$OUT/bracken-db.qza" \
    --verbose
else
  echo "DBs exist, skipping"
fi


echo "2. Kraken2 classification: $(date)"
mosh annotate classify-kraken2 \
  --i-seqs "$READS" \
  --i-kraken2-db "$OUT/kraken2-db.qza" \
  --p-threads "$THREADS" \
  --p-confidence "$CONFIDENCE" \
  --p-memory-mapping False \
  --o-reports "$OUT/kraken2-reports.qza" \
  --o-outputs "$OUT/kraken2-outputs.qza" \
  --verbose

echo "3. Bracken abundance re-estimation: $(date)"
mosh annotate estimate-bracken \
  --i-kraken-reports "$OUT/kraken2-reports.qza" \
  --i-bracken-db "$OUT/bracken-db.qza" \
  --p-read-len "$READ_LEN" \
  --p-level S \
  --o-reports "$OUT/bracken-reports.qza" \
  --o-taxonomy "$OUT/bracken-taxonomy.qza" \
  --o-table "$OUT/bracken-table.qza" \
  --verbose

echo "4. Barplot: $(date)"
qiime taxa barplot \
  --i-table "$OUT/bracken-table.qza" \
  --i-taxonomy "$OUT/bracken-taxonomy.qza" \
  --m-metadata-file "$META" \
  --o-visualization "$OUT/bracken-barplot.qzv"

echo "FINISHED $(date)"