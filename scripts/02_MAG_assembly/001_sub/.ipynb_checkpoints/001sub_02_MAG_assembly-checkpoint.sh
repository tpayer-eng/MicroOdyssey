#!/bin/bash
#SBATCH --job-name=02_MAG_QC
#SBATCH --mail-type=END
#SBATCH --time=24:00:00
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
output_dir="../../../output/MAG_assembly/001sub/"


echo "contig QC: start"
qiime assembly evaluate-quast \
    --i-contigs $output_dir/contigs-sub001.qza \
    --p-min-contig 500 \
    --p-threads 6 \
    --o-visualization $output_dir/contigs-sub001.qzv \
    --o-results-table $output_dir/quast-results-sub001.qza \
    --o-reference-genomes $output_dir/quast-refs-sub001.qza
echo "contig QC: end"
    
    
echo "mapping reads to contigs: start"
qiime assembly index-contigs \
    --i-contigs $output_dir/contigs-sub001.qza \
    --p-threads 6 \
    --p-seed 100 \
    --o-index $output_dir/contigs-index-sub001.qza
    
qiime assembly map-reads \
    --i-index $output_dir/contigs-index-sub001.qza \
    --i-reads $data_dir/reads-sub001.qza \
    --p-threads 6 \
    --p-seed 100 \
    --o-alignment-maps $output_dir/reads-to-contigs-aln-sub001.qza
echo "mapping reads to contigs: end"
  
  
echo "contig binning: start"
qiime mag bin-contigs-metabat \
    --i-contigs $output_dir/contigs-sub001.qza \
    --i-alignment-maps $output_dir/reads-to-contigs-aln-sub001.qza \
    --p-num-threads 6 \
    --p-seed 100 \
    --o-mags $output_dir/mags-sub001.qza \
    --o-contig-map $output_dir/contig-map-sub001.qza \
    --o-unbinned-contigs $output_dir/unbinned-contigs-sub001.qza
echo "contig binning: end"


echo "MAG QC: start"
qiime mag fetch-busco-db \
    --p-lineages bacteria_odb12 \
    --o-db $output_dir/busco-db-bacteria-sub001.qza
    
qiime mag evaluate-busco \
    --i-mags $output_dir/mags-sub001.qza \
    --i-db $output_dir/busco-db-bacteria-sub001.qza \
    --i-unbinned-contigs $output_dir/unbinned-contigs-sub001.qza \
    --p-lineage-dataset bacteria_odb12 \
    --p-cpu 6 \
    --o-results $output_dir/busco-results-sub001.qza \
    --o-visualization $output_dir/mags-sub001.qzv
    
qiime mag filter-mags \
    --i-mags $output_dir/mags-sub001.qza \
    --m-metadata-file $output_dir/busco-results-sub001.qza \
    --p-where "completeness>50 AND contamination<10" \
    --p-on "mag" \
    --o-filtered-mags $output_dir/mags-filtered-sub001.qza
echo "MAG QC: end"
    

echo "MAG dereplication: start"
qiime sourmash compute \
    --i-sequence-file $output_dir/mags-filtered-sub001.qza \
    --p-ksizes 105 \
    --p-scaled 100 \
    --o-min-hash-signature $output_dir/mags-hashes-sub001.qza

qiime sourmash compare \
    --i-min-hash-signature $output_dir/mags-hashes-sub001.qza \
    --p-ksize 105 \
    --o-compare-output $output_dir/mags-dist-sub001.qza
    
qiime mag dereplicate-mags \
    --i-mags $output_dir/mags-filtered-sub001.qza \
    --i-distance-matrix $output_dir/mags-dist-sub001.qza \
    --m-metadata-file $output_dir/busco-results-sub001.qza \
    --p-metadata-column "completeness" \
    --p-threshold 0.7 \
    --o-dereplicated-mags $output_dir/mags-derep-sub001.qza \
    --o-table $output_dir/mags-table-pa-sub001.qza
echo "MAG dereplication: end"

echo "script 02 MAG assembly: end $(date)"

