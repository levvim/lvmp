#!/usr/bin/env Rscript

# This script runs CNV calling on paired normal/tumor bams.

# load library
library(facets)

# set seed for consistent sampling of SNPs for reproducibility
set.seed(1234)

# input arguments
args <- commandArgs(TRUE)
sample_name <- args[1]
snp_pileup <- args[2]
output_path <- args[3]

# processing
rcmat <- readSnpMatrix(snp_pileup)
xx <- preProcSample(rcmat)
oo <- procSample(xx, cval=150)

# compute copy number information
fit <- emcncf(oo)

# further processing
newcols <- c("chromosome", "start", "end", "copy_number", "minor_cn", "major_cn", 
            "cellular_prevalence")
copy_num <- fit$cncf[13] + fit$cncf[14]
res <- cbind(fit$cncf[c(1, 10, 11)], copy_num, fit$cncf[c(14, 13, 12)])
colnames(res) <- newcols
res <- res[!is.na(res$minor_cn) & !is.na(res$major_cn),]

# write to file
output_file = paste(output_path, "/", sample_name, ".facets_output.txt", sep="")
write.table(res, file=output_file, quote=F, col=T, row=F, sep="\t")
