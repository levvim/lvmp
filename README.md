# lvmp: A genomics pipeline framework

## lvmp is a collection of deployable genomics pipelines constructed in a methodical framework using Docker and Snakemake. We can alter, reconstruct and add functions quickly using a modular structure. This structure can also scale for large parallel analyses and can deploy in different cluster environments.

Our file structure uses a directory for a given project, and subdirectories for each step. As the pipeline progresses we create intermediary files across step specific directories until we reach our final output. The pipeline specific dependencies are stored in separate `scripts`, `container`, and `reference` directories. The pipeline metrics are stored in a project specific log folder. Example:

    |-scripts
    |---Snakefile_align
    |-references
    |---hg19.fasta
    |-containers
    |---bwa.simg
    |-PROJECT1
    |---fastq
    |-----sample1.01.fastq
    |-----sample1.02.fastq
    |---bam
    |-----sample1.bam
    
The following pipelines are constructed:

* Mutation Calling
    * Preprocessing
    * Mutation Calling
    * Mutation Filtering
* Neoantigen Calling
    * HLA Typing    
    * Class I Neoantigen Calling
    * Class II Neoantigen Calling
* RNA Expression
    * Preprocessing
    * FPKM, TPM, Counts based Gene Quantification

The installation and run instructions can be found in `SETUP.md` and lauched via `snakemake` or `lvmp_sub`. The only dependencies outside of containers are Snakemake and Singularity/Docker.
