#!/bin/bash
#SBATCH --job-name=02_assemble_map
#SBATCH --partition=normal.24h
#SBATCH --time=20:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G
#SBATCH --tmp=60G
#SBATCH --array=1-2%20 # after successful test, raise to 234
#SBATCH --output=logs/%x_%A_%a.out

echo "sourcing bashrc: start"
source ~/.bashrc
conda activate rachis-moshpit-2026.7
set -euo pipefail
echo "sourcing bashrc: end"

echo "dir definitions: start"
output_dir=../../output/06_functionalannotation
fastq_dir=$output_dir/fastq
contig_dir=$output_dir/contig
mapping_dir=$output_dir/mapping
MIN_LEN=1000
THREADS=$SLURM_CPUS_PER_TASK
MEGAHIT_MEM=3500000000
WORK=${SLURM_TMPDIR:-${TMPDIR:-/tmp}}/work_${SLURM_ARRAY_JOB_ID:-0}_${SLURM_ARRAY_TASK_ID:-0}
mkdir -p "$contig_dir" "$mapping_dir" logs
S=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$output_dir/samples.txt")
echo "sample: $S"
echo "dir definitions: end"

if [ -s "$contig_dir/${S}_contigs.fa" ] && [ -s "$mapping_dir/${S}.idxstats.tsv" ]; then
  echo "already done, skipping"; exit 0
fi

R1=$(awk -F, -v s="$S" '$1==s && $3=="forward"{print $2}' "$fastq_dir/MANIFEST")
R2=$(awk -F, -v s="$S" '$1==s && $3=="reverse"{print $2}' "$fastq_dir/MANIFEST")
if [ -n "$R2" ]; then
  MH_IN="-1 $fastq_dir/$R1 -2 $fastq_dir/$R2"; BT_IN="-1 $fastq_dir/$R1 -2 $fastq_dir/$R2"
else
  MH_IN="-r $fastq_dir/$R1";               BT_IN="-U $fastq_dir/$R1"
fi

rm -rf "$WORK"; mkdir -p "$WORK"
trap 'rm -rf "$WORK"' EXIT
echo "assembly: start $(date)"
megahit $MH_IN --presets meta-sensitive --min-contig-len $MIN_LEN \
  -t "$THREADS" -m $MEGAHIT_MEM -o "$WORK/megahit" --out-prefix "$S"
# make contig IDs unique across samples (prefix with sample ID)
sed "s/^>/>${S}_/" "$WORK/megahit/${S}.contigs.fa" > "$contig_dir/${S}_contigs.fa"
echo "contigs: $(grep -c '^>' "$contig_dir/${S}_contigs.fa")"
echo "assembly: end $(date)"

echo "mapping: start $(date)"
bowtie2-build --threads "$THREADS" -q "$contig_dir/${S}_contigs.fa" "$WORK/idx"
bowtie2 -x "$WORK/idx" $BT_IN -p "$THREADS" 2> "$mapping_dir/${S}.bowtie2.log" \
  | samtools sort -@ "$THREADS" -o "$WORK/s.bam" -
samtools index "$WORK/s.bam"
# per contig: name, length, mapped reads, unmapped; last line '*' = unplaced reads
samtools idxstats "$WORK/s.bam" > "$mapping_dir/${S}.idxstats.tsv"
tail -n 1 "$mapping_dir/${S}.bowtie2.log"       # overall alignment rate
echo "mapping: end $(date)"
