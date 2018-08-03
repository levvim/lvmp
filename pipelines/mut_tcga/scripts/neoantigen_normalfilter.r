#levim for wolchok lab 2016
#filter out candidate epitopes that were also expressed in the normal
#using *.tumor.pan and *.normal.pan
#called as 'Rscript ~/scripts/neoantigen_normalfilter.r "$sample"."$hla".tumor.pan "$sample"."$hla".normal.pan "$sample"."$hla".filter.pan'


#args are passed as Rscript --vanilla tumor.pan.xls normal.pan.xls output.tsv $WORK_DIR
args=commandArgs(trailingOnly=TRUE)

#test data
#setwd("~/../../projects/advaxis/neoantigen")
#tumor = read.table("IO33_CACTTCGA_A-J-F3_CGAACTTA.H-2-Kk.tumor.pan", sep="\t", stringsAsFactors=FALSE, fill=TRUE, header=FALSE, row.names=NULL)
#normal = read.table("IO33_CACTTCGA_A-J-F3_CGAACTTA.H-2-Kk.normal.pan", sep="\t", stringsAsFactors=FALSE, fill=TRUE, header=FALSE, row.names=NULL)
#output="test_output.txt"

#read in data
setwd(args[4])
tumor = read.table(as.character(args[1]), sep="\t", stringsAsFactors=FALSE, header=FALSE, fill=TRUE,   row.names=NULL)
normal = read.table(as.character(args[2]), sep="\t", stringsAsFactors=FALSE, header=FALSE, fill=TRUE, row.names=NULL)
output = args[3]

#cnames = c("kmer", "chr", "loci", "gene", "core", "epi", "peplist", "epi2", "1-log50k", "nM", "Rank", "Ave", "SB")
#cnames = c("kmer", "chr", "loci", "gene", "core", "epi",  "1-log50k", "nM", "Rank", "Ave", "SB")
#cnames = c("Pos", "Peptide", "ID", "1-log50k", "nM", "Rank", "Ave", "NB")

cnames = c("kmer", "chr", "loci", "gene", "core", "epi", "peplist", "epi2", "1-log50k", "nM", "Rank", "Ave", "SB")
colnames(tumor) = cnames
colnames(normal) = cnames

#tumor = tumor[3:length(tumor[,1]),]  
#normal = normal[3:length(normal[,1]),]  
#give row IDs to the files: these two files should have the same order/length of epitopes for comparison
tumor$ID=seq.int(nrow(tumor))
normal$ID=seq.int(nrow(normal))

#add SB field manually if nonexistent
#tumor$SB=0
#tumor[tumor$"nM" < .06,]$SB = 1
#normal$SB=0
#normal[normal$nM < .06,]$SB = 1

#grep out SB epitopes
#tumor$SB = as.numeric(tumor$SB);   tumor = tumor[tumor$SB==1,]
#normal$SB = as.numeric(normal$SB);   normal = normal[normal$SB==1,]
tumor = tumor[tumor$SB==1,]
normal = normal[normal$SB==1,]


#for those in tumor SB epitopes, select those which are not matched in the normal SB list
tumor.filter=tumor[!tumor$ID %in% c(normal$ID),] 

head(tumor.filter)
dim(tumor)
dim(tumor.filter)

#output as tsv
write.table(tumor.filter, file=output, sep="\t", row.names=FALSE, quote = FALSE)
