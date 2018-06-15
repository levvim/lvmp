# lvmp mut_msk

### Preprocessing, mutation calling and filtering of human genomes based on the MSK pipeline. This pipeline utilizes a single caller setup (MuTect) + rescue + filtering and vep annotation.

This pipeline is called in 3 parts: Preprocessing, mutation calling then filtering. An example workflow of the corresponding Snakefiles are as follows:

    #For sample preprocessing (from *.fastq to *.pp.bam):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.N sample1.T sample2.N sample2.T"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_prepro" 

    #For mutation calling (from *.pp.bam to *.vcf for muTect and HaplotypeCaller respectively):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1 sample2"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_mut" 

    #For Mutation filtering, rescue and annotation (from *.vcf to *.maf for muTect and HaplotypeCaller respectively, as well as a merged *.maf with vep annotation):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1 sample2"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_mut_filter" 

We can also start this fom a previously aligned \*.bam file by first running a conversion fastq:

    #For converting back to raw reads (from *.bam to *.fastq):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.N sample1.T sample2.N sample2.T"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_b2f" 
