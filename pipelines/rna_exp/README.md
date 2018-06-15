# lvmp rna_exp

### This is a 'best practices' RNA pipeline to align files and calulate gene level expression. 

We use two methods (featureCounts and kallisto) to determine FPKM, TPM, RPKM and counts based expression.

    #For sample preprocessing (from *.fastq to *.merge.bam.txt):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.N sample1.T sample2.N sample2.T"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_rna" 

We can also start this fom a previously aligned \*.bam file by first running a conversion fastq:

    #For converting back to raw reads (from *.bam to *.fastq):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.N sample1.T sample2.N sample2.T"; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_b2f" 
