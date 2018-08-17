# lvmp_aws
## Setup and workflow for running genomics pipelines on aws EC2
## We have set up a means to initialize this pipeline to run on ec2 instances (using the basic Amazon Linux 2 AMI). The workflow is as follows (rna expression of a single sample):

Run generalized setup script. This will update the system and install pipeline dependencies (clone pipeline, folder structure, container system, permissions etc)

    curl https://raw.githubusercontent.com/levvim/lvmp/master/lvmp_ec2 -o ~/lvmp_ec2
    chmod u+x ~/lvmp_ec2
    ~/lvmp_ec2 -u ec2-user -k "access_key" -s "secret_key"

Pull relevant containers

    cd ~/CONTAINERS/
    singularity pull docker://levim/hgrna:1.1
    singularity pull docker://broadinstitute/picard:latest

Pull reference set and project files

    aws s3 cp --recursive s3://immunoseqexternal/COMPUTE/refs/GRCh37hg19/ /home/ec2-user/REFS/
    aws s3 cp --recursive s3://immunoseqexternal/COMPUTE/refs/ENSEMBL.homo_sapiens.release-75/ /home/ec2-user/REFS/ENSEMBL.homo_sapiens.release-75/

    aws s3 cp s3://RNASeq/FASTQ_Files/Sample_SK_MEL_301T-tumor-R1-cat.fastq /home/ec2-user/PROJECT/rnatest/rna_fastq/Sample_SK_MEL_301T.L1.01.fastq
    aws s3 cp s3://RNASeq/FASTQ_Files/Sample_SK_MEL_301T-tumor-R2-cat.fastq /home/ec2-user/PROJECT/rnatest/rna_fastq/Sample_SK_MEL_301T.L1.02.fastq

Create any additional project dirs

    mkdir -p ~/PROJECT/rnatest/tmp/

Run pipeline

    REFS="/home/ec2-user/REFS/ENSEMBL.homo_sapiens.release-75/"
    CONTAINERS="/home/ec2-user/CONTAINERS/"
    SNAKEFILE="/home/ec2-user/lvmp/pipelines/rna_exp/scripts/Snakefile_rna1.1"
    WORKDIR="/home/ec2-user/PROJECT/rnatest/"
    SAMPLES="Sample_SK_MEL_301T"
    RID="L1"

    snakemake \ -d $WORKDIR \ --snakefile $SNAKEFILE \ --rerun-incomplete \ --latency-wait 120 \ --config refs="$REFS" scripts="$SCRIPTS" containers="$CONTAINERS" samples="$SAMPLES" file="$WORKDIR" RID="$RID"
