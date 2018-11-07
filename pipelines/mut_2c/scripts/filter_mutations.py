#!/usr/bin/env python3

# This script combines raw MuTect and Strelka mutations.

# import packages
import argparse

# input arguments
parser = argparse.ArgumentParser()
parser.add_argument("patient", help="Patient name.")
parser.add_argument("mutect_results", help="Mutect results.")
parser.add_argument("strelka_results", help="Strelka results.")
parser.add_argument("normal_readcounts_file", help="Normal base readcounts.")
parser.add_argument("tumor_readcounts_file", help="Tumor base readcounts.")
parser.add_argument("output_path", help="Output path for vcfs with union of called mutations and each caller's mutations.")
args = parser.parse_args()
patient = args.patient
mutect_results = args.mutect_results
strelka_results = args.strelka_results
normal_readcounts_file = args.normal_readcounts_file
tumor_readcounts_file = args.tumor_readcounts_file
output_path = args.output_path

# important filtering data
bases = ["A", "C", "G", "T"]
chromosomes = [str(c) for c in list(range(1,23))] + ["X", "Y", "MT"]

# functions

# read in bam readcounts for the number of reads at a position
def readcounts(readcounts_file):
    with open(readcounts_file, "r") as f:
        lines = [l.strip("\n").split("\t") for l in f.readlines()]
    data_dict = {}
    for l in lines:
        chrom = l[0]
        pos = l[1]
        mini_dict = {}
        for sme in l[5:]:
            sme = sme.split(":")
            base = sme[0]
            count = int(sme[1])
            mini_dict[base] = count
        data_dict["{}_{}".format(chrom, pos)] = mini_dict
    return data_dict

# read in MuTect output
def mutect_filter(stats_file, normal_readcounts, tumor_readcounts):
    with open(stats_file, "r") as f:
        raw_lines = [l.strip("\n").split("\t") for l in f.readlines()]
    mutations = []
    for l in raw_lines:
        chrom = l[0]
        pos = l[1]
        ref = l[3]
        alt = l[4]
        loc = "{}_{}".format(chrom, pos)
        if (ref in bases and alt in bases and
            chrom in chromosomes and
            loc in normal_readcounts.keys() and
            loc in tumor_readcounts.keys()):
            # specific filters
            judgement = l[-1]
            if judgement != "REJECT":
                mut = "_".join([chrom, pos, ref, alt, patient])
                mutations.append(mut)
    mutations = set(mutations)
    return mutations

# read in Strelka output
def strelka_filter(vcf_file, normal_readcounts, tumor_readcounts):
    with open(vcf_file, "r") as f:
        raw_lines = [l.strip("\n").split("\t") for l in f.readlines() if l[0] != "#"]
    mutations = []
    for l in raw_lines:
        chrom = l[0]
        pos = l[1]
        ref = l[3]
        alt = l[4]
        loc = "{}_{}".format(chrom, pos)
        if (ref in bases and alt in bases and
            chrom in chromosomes and
            loc in normal_readcounts.keys() and
            loc in tumor_readcounts.keys()):
            mut = "_".join([chrom, pos, ref, alt, patient])
            mutations.append(mut)
    mutations = set(mutations)
    return mutations

# analysis

# readcounts
normal_readcounts = readcounts(normal_readcounts_file)
tumor_readcounts = readcounts(tumor_readcounts_file)

# mutations
mutect_muts = mutect_filter(mutect_results, normal_readcounts, tumor_readcounts)
strelka_muts = strelka_filter(strelka_results, normal_readcounts, tumor_readcounts)

# union of mutations
called_muts = mutect_muts | strelka_muts

# write mutations to VCF
title = ["#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", "NORMAL", "TUMOR"]
to_write = ["\t".join(title)]
for mut in called_muts:
    # this is since the sample is just one word without underscores (such as AL4602)
    chrom, pos, ref, alt, patient = mut.split("_")

    # reads
    loc = "{}_{}".format(chrom, pos)
    n_ref = normal_readcounts[loc][ref]
    n_alt = normal_readcounts[loc][alt]
    n_tot = n_ref + n_alt

    t_ref = tumor_readcounts[loc][ref]
    t_alt = tumor_readcounts[loc][alt]
    t_tot = t_ref + t_alt

    stuff = ["chr{}".format(chrom), pos, mut, ref, alt, ".", "PASS", "INFO", "DP:AP", 
             "{}:{}".format(n_tot, n_ref), "{}:{}".format(t_tot, t_ref)]

    # append line to VCFs
    stuff = "\t".join(stuff)
    to_write.append(stuff)

with open("{}/{}.vcf".format(output_path, patient), "w") as f:
    f.write("\n".join(to_write))
