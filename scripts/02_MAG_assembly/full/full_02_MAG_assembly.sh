#!/bin/bash
#SBATCH --job-name=full_02_MAG_assembly
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
data_dir=" ../../../data/raw"
output_dir="../../../output/MAG_assembly/full/"
echo "dir definitions: end"


echo "contig QC: start $(date)"
qiime assembly evaluate-quast \
    --i-contigs $output_dir/contigs.qza \
    --p-min-contig 500 \
    --p-threads 6 \
    --o-visualization $output_dir/contigs.qzv \
    --o-results-table $output_dir/quast-results.qza \
    --o-reference-genomes $output_dir/quast-refs.qza
echo "contig QC: end $(date)"
    
    
echo "mapping reads to contigs: start $(date)"
qiime assembly index-contigs \
    --i-contigs $output_dir/contigs.qza \
    --p-threads 6 \
    --p-seed 100 \
    --o-index $output_dir/contigs-index.qza
    
qiime assembly map-reads \
    --i-index $output_dir/contigs-index.qza \
    --i-reads $data_dir/reads.qza \
    --p-threads 6 \
    --p-seed 100 \
    --o-alignment-maps $output_dir/reads-to-contigs-aln.qza
echo "mapping reads to contigs: end $(date)"
  
  
echo "contig binning: start $(date)"
qiime mag bin-contigs-metabat \
    --i-contigs $output_dir/contigs.qza \
    --i-alignment-maps $output_dir/reads-to-contigs-aln.qza \
    --p-num-threads 6 \
    --p-seed 100 \
    --o-mags $output_dir/mags.qza \
    --o-contig-map $output_dir/contig-map.qza \
    --o-unbinned-contigs $output_dir/unbinned-contigs.qza
echo "contig binning: end $(date)"


echo "MAG QC: start $(date)"
qiime mag fetch-busco-db \
    --p-lineages bacteria_odb12 \
    --o-db $output_dir/busco-db-bacteria.qza
    
qiime mag evaluate-busco \
    --i-mags $output_dir/mags.qza \
    --i-db $output_dir/busco-db-bacteria.qza \
    --i-unbinned-contigs $output_dir/unbinned-contigs.qza \
    --p-lineage-dataset bacteria_odb12 \
    --p-cpu 6 \
    --o-results $output_dir/busco-results.qza \
    --o-visualization $output_dir/mags.qzv
    
qiime mag filter-mags \
    --i-mags $output_dir/mags.qza \
    --m-metadata-file $output_dir/busco-results.qza \
    --p-where "completeness>50 AND contamination<10" \
    --p-on "mag" \
    --o-filtered-mags $output_dir/mags-filtered.qza
echo "MAG QC: end $(date)"
    

echo "MAG dereplication: start $(date)"
qiime sourmash compute \
    --i-sequence-file $output_dir/mags-filtered.qza \
    --p-ksizes 105 \
    --p-scaled 100 \
    --o-min-hash-signature $output_dir/mags-hashes.qza

qiime sourmash compare \
    --i-min-hash-signature $output_dir/mags-hashes.qza \
    --p-ksize 105 \
    --o-compare-output $output_dir/mags-dist.qza
    
qiime mag dereplicate-mags \
    --i-mags $output_dir/mags-filtered.qza \
    --i-distance-matrix $output_dir/mags-dist.qza \
    --m-metadata-file $output_dir/busco-results.qza \
    --p-metadata-column "completeness" \
    --p-threshold 0.7 \
    --o-dereplicated-mags $output_dir/mags-derep.qza \
    --o-table $output_dir/mags-table-pa.qza
echo "MAG dereplication: end $(date)"

