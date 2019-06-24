# lvmp quantiseq

### This is a pipeline to run Quantiseq on rnaseq data.

For a run similar to the samples below, we set up the snakemake arguments as follows

```
sample1.R.L1.01.fastq.gz
sample1.R.L1.02.fastq.gz
sample2.R.L1.01.fastq.gz
sample2.R.L1.02.fastq.gz
sample2.R.L2.01.fastq.gz
sample2.R.L2.02.fastq.gz
```

    #For sample preprocessing (from *.fastq.gz to *.cell_fractions.txt):
    WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.R sample2.R "; RID="L1 L2"; SNAKEFILE="$HOME/lvmp/lvmp/pipelines/quantiseq/scripts/Snakefile_quantiseq" 



