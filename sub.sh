# levim Wolchok lab 2017
# Script to organize a snakefile pipeline configurations

# Pipeline format:
################################################################################
# Project Config

USER="ec2-user"
WORKDIR="/home/$USER/PROJECT/";
SAMPLES=" "; 
RID="L1";
SNAKEFILE="/home/$HOME/PROJECT/lvmp/pipelines/ "

################################################################################
REFS="/home/$USER/REFS/GRCh37hg19/"
SCRIPTS="/home/$USER/SCRIPTS/"
CONTAINERS="/home/$USER/CONTAINERS/"
NUM_JOBS=100 #number of jobs running in parallel 

################################################################################
# Config from CLI

#WORKDIR=$1
#SNAKEFILE=$2
#SAMPLES=$3
#NUM_JOBS=$4
#RID=$5
#NUM_JOBS=$6
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

# Delete log files
#rm "$WORKDIR"log/*
        
# Make workdirs for outputs if running for the first time
cd $WORKDIR 
dirs=("tmp" "log" "rna_fastq" "fastq" "counts" "fastqc" "indelrealign" "bqsr" "merge" "optitype" "snpeff" "clean" "index" "muTect" "muTect2" "strelka" "strelka2" "manta" "varscan2" "somaticsniper" "bam" "markdup" "sam" "sort" "HC")
for ((i=0;i<${#dirs[@]};++i)); do mkdir -p ${dirs[$i]}; done

################################################################################
# Run
# Dry run
snakemake \
    -d $WORKDIR \
    --config refs="$REFS" scripts="$SCRIPTS" containers="$CONTAINERS" samples="$SAMPLES" file="$WORKDIR" RID="$RID" \
    --snakefile $SNAKEFILE --dag | dot -Tpdf > "$SNAKEFILE"_dag.pdf

# Local submission
snakemake  -d $WORKDIR  --snakefile $SNAKEFILE  --rerun-incomplete  --latency-wait 120  --config refs="$REFS" scripts="$SCRIPTS" containers="$CONTAINERS" samples="$SAMPLES" file="$WORKDIR" RID="$RID"

## Cluster submission 
#snakemake \
#    -d $WORKDIR \
#    --latency-wait 120 \
#    --jobs $NUM_JOBS \
#    --snakefile $SNAKEFILE \
#    --rerun-incomplete \
#    --cluster "bsub -W {params.walltime} -R rusage[mem={params.mem}] -n {params.threads} -o $WORKDIR/log/o{params.name}.log -e $WORKDIR/log/e{params.name}.log" \
#    --config refs="$REFS" scripts="$SCRIPTS" containers="$CONTAINERS" samples="$SAMPLES" file="$WORKDIR" RID="$RID" 

################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
