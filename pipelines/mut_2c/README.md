# lvmp mut_2c



### Preprocessing, mutation calling and filtering of human genomes based on a 'best practices' 2 caller pipeline. This pipeline utilizes a 2 caller setup (Mutect1, Strelka1) with annotation via snpEff.

SETUP: This pipeline requires the relevant singularity/docker images in addition to snakemake:
    
    singularity pull docker://aarjunrao/cutadapt:1.9.1
    singularity pull docker://levim/dsprepro:1.1
    singularity pull docker://levim/hgmut:1.0
    singularity pull docker://levim/picard:2.11
    singularity pull docker://broadinstitute/gatk3:3.8-1
    singularity pull docker://levim/mutect:1.1.7
    singularity pull docker://levim/samtools:1.9
    singularity pull docker://levim/bwa:0.7.17

This pipeline is called in 2 parts starting with fastq files: Preprocessing, then  mutation calling/filtering. Note that fastq files follow the nomenclature `sample.[T/N].lane.pair.fastq`, i.e. `sample1.T.L1.01.fastq`. An example workflow of the corresponding Snakefiles are as follows:

    #For sample preprocessing (from *.fastq to *.pp.bam):
    WORKDIR="/levvim/PROJECT1/";
        SAMPLES="sample1.N sample1.T sample2.N sample2.T";
        RID="L1 L2"; 
        SNAKEFILE="$HOME/scripts/Snakefile_prepro" 

    #For mutation calling (from *.pp.bam to *.vcf *.vcf.ann for muTect and strelka respectively with snpEff annotation):
    WORKDIR="/levvim/PROJECT1/"; 
        SAMPLES="sample1 sample2"; 
        RID="L1 L2"; 
        SNAKEFILE="$HOME/scripts/Snakefile_mut" 

We can also start this fom a previously aligned \*.bam file by first running a conversion back to fastq:

    #For converting back to raw reads (from *.bam to *.fastq):
    WORKDIR="/levvim/PROJECT1/"; 
        SAMPLES="sample1.N sample1.T sample2.N sample2.T"; 
        RID="L1 L2"; 
        SNAKEFILE="$HOME/scripts/Snakefile_b2f" 

The rest of the arguments are fixed and submission to a cluster is as follows:

    #Define resource directories
    FILE="/data/"
    CONTAINERS="/containers/"
    REFS="/refs/"
    SCRIPTS="/scripts/"
    NUM_JOBS=8 #number of jobs running in parallel 

    cd $WORKDIR 
    dirs=("tmp" "bqsr" "log" "fastq" "fastqc" "indelrealign" "bqsr" "merge" "clean" "index" "muTect" "strelka" "bam" "markdup" "sam" "sort")

    #Start pipeline
    $SNAKEMAKE \
        -d $WORKDIR \
        --latency-wait 120 \
        --jobs $NUM_JOBS \
        --snakefile $SNAKEFILE \
        --rerun-incomplete \
        --cluster "bsub -W {params.walltime} -R rusage[mem={params.mem}] -n {params.threads} -o $WORKDIR/log/o{params.name}.log -e $WORKDIR/log/e{params.name}.log" \
        --config refs="$REFS" scripts="$SCRIPTS" containers="$CONTAINERS" samples="$SAMPLES" file="$WORKDIR" RID="$RID"
