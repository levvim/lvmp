# Setup for lvmp pipeline
## Specify installation and setup directories for pipeline dependencies

    FILE="/data/"
    CONTAINERS="/containers/"
    REFS="/refs/"
    SCRIPTS="/scripts/"
    
    mkdir -p $FILE $CONTAINERS $REFS

## Install necessary containers
#### This pipeline was originally developed using singularity (https://singularity.lbl.gov/index.html) containers in a cluster. If you are not using Singularity through environment modules, delete or comment out the `module add singularity;` lines from shell commands. Singularity installation is straightforward (taken from https://singularity.lbl.gov/install-linux): 

    VERSION=2.5.1
    wget https://github.com/singularityware/singularity/releases/download/$VERSION/singularity-$VERSION.tar.gz
    tar xvf singularity-$VERSION.tar.gz
    cd singularity-$VERSION
    ./configure --prefix=/usr/local
    make
    sudo make install

#### If you are using singularity:

    #module add singularity;
    cd $CONTAINERS
    singularity pull docker://aarjunrao/cutadapt:1.9.1
    singularity pull docker://aarjunrao/mutect:1.1.7
    singularity pull docker://levim/cutadapt-1.16:latest
    singularity pull docker://levim/dsprepro:1.1
    singularity pull docker://broadinstitute/picard:latest
    singularity pull docker://biodckrdev/gatk:3.4
    singularity pull docker://biocontainers/bcftools:1.3.1
    singularity pull docker://levim/vep_samtools:1.0

#### The pipeline can be run in a Docker environement as well (change all of the `singularity exec --bind` to `docker run -v` and remove image filepath prefixes).
#### For Docker:
    
    cd $CONTAINERS
    docker pull aarjunrao/cutadapt:1.9.1
    docker pull levim/cutadapt-1.16:latest
    docker pull levim/dsprepro:1.1
    docker pull broadinstitute/picard:latest
    docker pull biodckrdev/gatk:3.4
    docker pull biocontainers/bcftools:1.3.1
    docker pull levim/vep_samtools:1.0

## Install Snakemake (locally)
#### Follow the lines below to download/install miniconda and specify the installation directory within your `SCRIPTS` folder:

    cd $SCRIPTS
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod u+x Miniconda3-latest-Linux-x86_64.sh
    ./Miniconda3-latest-Linux-x86_64.sh

#### Install Snakemake (this will also have prompts):

    $SCRIPTS/miniconda3/bin/conda install -c bioconda -c conda-forge snakemake

## Download reference genomes
#### You will need to download the according necessary human GRCh37 (b37) reference genomes (available from the Broad Resource Bundle https://software.broadinstitute.org/gatk/download/bundle) into your REFS folder.

    human_g1k_b37.fasta
    dbsnp_138.b37.vcf
    dbsnp_138.b37.excluding_sites_after_129.vcf
    CosmicCodingMuts.vcf
    Mills_and_1000G_gold_standard.indels.b37.vcf
    hapmap_3.3.b37.vcf
    1000G_omni2.5.b37.vcf
    1000G_phase1.snps.high_confidence.b37.vcf
    human.exome.b37.interval_list

# To run:
### Set up a project directory (i.e. `PROJECT1`) and transfer your raw fastq files into the `fastq` subdirectory.
#### The fastq files MUST be in a `SAMPLE.LANE.PAIR.fastq` naming format. For example, for two paired end samples with matching normal and tumor sequencing running across two lanes would have the following files: 

    sample1.N.L1.01.fastq
    sample1.N.L1.02.fastq
    sample1.N.L2.01.fastq
    sample1.N.L2.02.fastq
    sample1.T.L1.01.fastq
    sample1.T.L1.02.fastq
    sample1.T.L2.01.fastq
    sample1.T.L2.02.fastq
    sample2.N.L1.01.fastq
    sample2.N.L1.02.fastq
    sample2.N.L2.01.fastq
    sample2.N.L2.02.fastq
    sample2.T.L1.01.fastq
    sample2.T.L1.02.fastq
    sample2.T.L2.01.fastq

#### Specify dependency directories:

    REFS="/levvim/refs/GRCh37hg19/"
    SCRIPTS="/levvim/scripts/"
    CONTAINERS="/levvim/singularity/"
    NUM_JOBS=100 #number of jobs running in parallel 

#### Specify project specific paramenters (project directory, samples, pipeline snakefile). Note that the formatting for this setup will change given on the step of the pipeline:

    #For sample preprocessing:
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.N sample1.T sample2.N sample2.T"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_hgsocci" 
    #For mutation calling:
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1 sample2"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_mut_socci" 
    #For Mutation filtering, rescue and annotation:
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1 sample2"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_mut_filter" 

#### For this example we are preprocessing these samples for downstream calling:

    WORKDIR="/levvim/PROJECT1/";
    SAMPLES="sample1.N sample1.T sample2.N sample2.T"
    RID="L1 L2" 
    SNAKEFILE="$HOME/scripts/Snakefile_hgsocci" 

#### Create project directories

    cd $WORKDIR 
    dirs=("tmp" "log" "fastq" "fastqc" "indelrealign" "bqsr" "merge" "clean" "index" "muTect" "bam" "markdup" "sam" "sort" "HC")
    for ((i=0;i<${#dirs[@]};++i)); do mkdir -p ${dirs[$i]}; done

### Run Snakemake
#### For Cluster submission, it is reccomended to run snakemake inside a low power interactive session with a long walltime so that it does not use the shared resources. 
#### It is also reccomended to run snakemake inside a gnu screen/tmux.

#### To perform a dry run and visualize workflow:
    
    $SCRIPTS/miniconda3/bin/snakemake \
        -d $WORKDIR \
        --config refs="$REFS" scripts="$SCRIPTS" containers="$CONTAINERS" samples="$SAMPLES" file="$WORKDIR" RID="$RID" \
        --snakefile $SNAKEFILE --dag | dot -Tpdf > "$SNAKEFILE"_dag.pdf

#### To submit to a Cluster queue:
#### The submission command is formatted to a Centos 7/IBM LSF scheduler. To submit on a different cluster type change the `--cluster` flag to match nomenclature.
    
    /home/mangaril/programs/miniconda3/bin/snakemake \
        -d $WORKDIR \
        --latency-wait 120 \
        --jobs $NUM_JOBS \
        --snakefile $SNAKEFILE \
        --rerun-incomplete \
        --cluster "bsub -W {params.walltime} -R rusage[mem={params.mem}] -n {params.threads} -o $WORKDIR/log/o{params.name}.log -e $WORKDIR/log/e{params.name}.log" \
        --config refs="$REFS" scripts="$SCRIPTS" containers="$CONTAINERS" samples="$SAMPLES" file="$WORKDIR" RID="$RID"

#### To submit inside a high power interactive session, start the session and run as follows:

    /home/mangaril/programs/miniconda3/bin/snakemake \
        -d $WORKDIR \
        --snakefile $SNAKEFILE \
        --rerun-incomplete \
        --config refs="$REFS" scripts="$SCRIPTS" containers="$CONTAINERS" samples="$SAMPLES" file="$WORKDIR" RID="$RID"


