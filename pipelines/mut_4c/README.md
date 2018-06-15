# lvmp mut_4c

### Preprocessing, mutation calling and filtering of human genomes based on the 'best practices' 4 caller pipeline. This pipeline utilizes a 4 caller setup (Mutect1, Strelka2, Varscan2, SomaticSniper) with annotation via snpEff.

This pipeline is called in 3 parts: Preprocessing, mutation calling then filtering. An example workflow of the corresponding Snakefiles are as follows:

    #For sample preprocessing (from *.fastq to *.pp.bam):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.N sample1.T sample2.N sample2.T"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_prepro" 

    #For mutation calling (from *.pp.bam to *.vcf *.vcf.ann for muTect, Strelka2, VarScan2 and SomaticSniper respectively with snpEff annotation):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1 sample2"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_mut" 

We can also start this fom a previously aligned \*.bam file by first running a conversion fastq:

    #For converting back to raw reads (from *.bam to *.fastq):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.N sample1.T sample2.N sample2.T"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_b2f" 
