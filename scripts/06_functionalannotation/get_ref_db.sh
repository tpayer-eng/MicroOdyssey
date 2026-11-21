# NOTE: this code was directly run on a login node of the cluster, since compute nodes often fail to access the internet
# 	(which is needed to get the reference databases)

# create temporary folder
export TMPDIR=/cluster/scratch/tpayer/tmp
mkdir -p $TMPDIR

# start session that survives disconnects
tmux new -s fetch

# setup
source ~/.bashrc
conda activate rachis-moshpit-2026.7
out=/cluster/scratch/tpayer/MicroOdyssey/output/06_functionalannotation/ref_db
mkdir -p $out

# get databases
mosh annotate fetch-diamond-db --o-db $out/diamond-db.qza --verbose
mosh annotate fetch-eggnog-db  --o-db $out/eggnog-db.qza  --verbose
