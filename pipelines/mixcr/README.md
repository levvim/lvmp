# lvmp rna_exp

### This is a pipeline to calculate B/T cell receptor repertoires

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
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.R sample2.R "; RID="L1 L2"; SNAKEFILE="$HOME/scripts/Snakefile_mixcr" 

This pipeline requires the human/mouse precompiled STAR genome as provided by Alex Dobin.

This pipeline requires the relevant singularity/docker images:
    
    singularity pull docker://levim/mixcr:1.0


