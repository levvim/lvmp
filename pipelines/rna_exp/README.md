# lvmp rna_exp

### This is a 'best practices' RNA pipeline to align files and calulate gene level expression. 

We use two methods (featureCounts and kallisto) to determine FPKM, TPM, RPKM and counts based expression.

For a run similar to the samples below, we set up the snakemake arguments as follows

```
sample1.R.L1.01.fastq.gz
sample1.R.L1.02.fastq.gz
sample2.R.L1.01.fastq.gz
sample2.R.L1.02.fastq.gz
sample2.R.L2.01.fastq.gz
sample2.R.L2.02.fastq.gz
```

    #For sample preprocessing (from *.fastq to *.merge.bam.txt):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.R sample2.R "; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_rna" 

This pipeline requires the human/mouse precompiled STAR genome as provided by Alex Dobin.

This pipeline requires the relevant singularity/docker images:
    
    singularity pull docker://levim/hgrna:1.0
    singularity pull docker://levim/dsprepro:1.1


