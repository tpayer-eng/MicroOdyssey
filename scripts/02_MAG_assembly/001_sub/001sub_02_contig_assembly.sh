#!/bin/bash
#SBATCH --job-name=02_MAG_assembly
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
# define data dir
data_dir="../../../data/raw"

output_dir="../../../output/MAG_assembly"
mkdir -p $output_dir
echo "dir definitions: end"

echo "subsampling: start $(date)"
qiime demux subsample-paired \
    --i-sequences $data_dir/reads.qza \
    --p-fraction 0.01 \
    --o-subsampled-sequences $data_dir/reads-sub001.qza
echo "subsampling: end $(date)"


echo "assembling genome: start $(date)"
qiime assembly assemble-megahit \
    --i-reads  $data_dir/reads-sub001.qza \
    --p-presets meta-large \
    --p-num-cpu-threads 6 \
    --o-contigs $output_dir/contigs-sub001.qza
echo "assembling genome: end $(date)"

##########################################################################################
#### IMPORTANT NOTE: I AM RUNNING A PROOF-OF-CONCEPT-TEST ON A 1% SUBSET OF THE READS ####
### FOR RUNNING MORE (DIDN'T YET FIND OUT HOW TO BEST RUN ON ALL), DO THE FOLLOWING: #####
### INCREASE TIME, INCREASE MEMORY (IF POSSIBLE), REMOVE SUBSAMPLING CODE, ETC ###########
##########################################################################################
    

