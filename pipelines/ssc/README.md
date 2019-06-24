# lvmp quantiseq

### This is a pipeline to run Kallisto Bus on single cell 10x data.

For a run similar to the samples below, we set up the snakemake arguments as follows

```
sample1.S.L1.01.fastq.gz
sample1.S.L1.02.fastq.gz
sample2.S.L1.01.fastq.gz
sample2.S.L1.02.fastq.gz
sample2.S.L2.01.fastq.gz
sample2.S.L2.02.fastq.gz
```

```
#For sample preprocessing (from *.fastq.gz to *.bus.txt):
WORKDIR="/levvim/PROJECT1/"; SAMPLES="sample1.S sample2.S "; RID="L1 L2"; SNAKEFILE="$HOME/lvmp/lvmp/pipelines/ssc/scripts/Snakefile_ssc" 
```


