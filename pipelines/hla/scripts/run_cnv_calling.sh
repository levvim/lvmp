#!/usr/bin/bash

# This script run CNV calling on paired normal/tumor bams.

# input arguments
sample_name=$1
normal_bam=$2
tumor_bam=$3
output_path=$4
run_facets_path=$5

REFS="/data/wolchok/PROJECT/refs/GRCh37hg19/"

# paths
dbsnp_path="$REFS/dbsnp_138.b37.vcf"
snp_pileup_path="/home/mangarin/programs/isnp-pileup/htstools/snp-pileup"

# create output path
mkdir -p $output_path

# snp-pileup
snp_pileup_output="$output_path""/""$sample_name"".csv.gz"
$snp_pileup_path 
--gzip -q15 -Q20 -P100 -r25,0 $dbsnp_path $snp_pileup_output $normal_bam $tumor_bam

echo "Done creating pileup file. Dispatching FACETS."

Rscript $run_facets_path $sample_name $snp_pileup_output $output_path
