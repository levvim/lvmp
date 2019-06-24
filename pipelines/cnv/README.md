# lvmp hla

Simple pipeline to call HLA types from normal WES data. Utilizes Optitype for Class I. We include a step to concatenate fastq files from different lanes to ensure proper coverage in the relevant regions.

    #For hla calling (from *.fastq to *.tsv formatted hla calls):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.N sample2.N"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_hla" 

Due to optitype output being date specific, a folder is created for each sample with the relevant calls (in \*.tsv).

This pipeline also requires the relevant singularity/docker images:
    
    singularity pull docker://levim/dsprepro:1.1
    singularity pull docker://fred2/optitype:release-v1.3.1
