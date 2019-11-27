#!/usr/bin/env python3

# This script makes the neoantigensStandardized file.

# import packages
import os
from collections import defaultdict
import argparse
import helper_funcs
helper_funcs = helper_funcs.helper_funcs()

# parser
parser = argparse.ArgumentParser()
parser.add_argument("--mt", "-m", help="mutated netMHC calls")
parser.add_argument("--wt", "-w", help="wildtype netMHC calls")
parser.add_argument("--hla", "-l", help="HLA calls")
parser.add_argument("--output_neo", "-n", help="output")
parser.add_argument("--output_fasta", "-f", help="output")
args = parser.parse_args()

# read in hlas
hlas_dict = helper_funcs.get_hlas(args.hla)
#with open(args.hla, "r") as f:
#    hla = [l.strip("\n").split("\t") for l in f.readlines()]
#    hla = [str(l) for l in hla.readlines()]
#hla = [i.replace(':', '') for i in hla]

# prepare lines for writing to file
#title = "\t".join(["ID", "MUTATION_ID", "Sample", 
#                   "WT.Peptide", "MT.Peptide", 
#                   "MT.Allele", "WT.Score", "MT.Score", "HLA"])
title = "\t".join(["ID", "MUTATION_ID", "Sample", 
                   "WT.Peptide", "MT.Peptide", 
                   "MT.Allele", "WT.Score", "MT.Score"])
to_write = [title]

# netmhc calls
mt_calls = args.mt
if os.path.exists(mt_calls):
    mt_calls = helper_funcs.read_netmhc_calls(mt_calls)
    wt_calls = args.wt
    wt_calls = helper_funcs.read_netmhc_calls(wt_calls)

    # organize lines for writing
    organize_pairs = helper_funcs.organize_pairs(wt_calls, 
                                                 mt_calls)

    for i in organize_pairs:
        i = "\t".join(i)
        to_write += [i]

# write neoantigensStandardized to file
with open(args.output_neo, "w") as f:
    f.write("\n".join(to_write) + "\n")

# extract .fasta files
fasta_dict = defaultdict(list)
for sme in to_write[1:]:
    sme = sme.split("\t")
    id_num = sme[0]
    mut_id = sme[0]
    sample = sme[1]
    wt_pep, mt_pep = sme[2], sme[3]
    stuff = ">{}|WT|{}|{}\n{}\n>{}|MUT|{}|{}\n{}\n".format(sample, id_num, mut_id, wt_pep, 
                                                           sample, id_num, mut_id, mt_pep)
    fasta_dict[sample].append(stuff)

for sample, data in fasta_dict.items():
    with open(args.output_fasta, "w") as f:
        print("".join(data))
        f.write("".join(data))

################################################################################
##!/usr/bin/env python3
#
## This script makes the neoantigensStandardized file.
#
## import packages
#import os
#from collections import defaultdict
#import helper_funcs
#helper_funcs = helper_funcs.helper_funcs()
#
## read in hlas
#hlas_dict = helper_funcs.get_hlas()
#
## prepare lines for writing to file
#title = "\t".join(["ID", "MUTATION_ID", "Sample", 
#                   "WT.Peptide", "MT.Peptide", 
#                   "MT.Allele", "WT.Score", "MT.Score", "HLA"])
#to_write = [title]
#data_dir = "../../results/netmhc_calls/"
#count = 1
#for sample_name in os.listdir(data_dir):
#    hlas = hlas_dict[sample_name]
#
#    # netmhc calls
#    mt_calls = "{}/{}/{}_mt_peps_netmhc_output.txt".format(data_dir, 
#                                                           sample_name, 
#                                                           sample_name)
#    if os.path.exists(mt_calls):
#        mt_calls = helper_funcs.read_netmhc_calls(mt_calls)
#        wt_calls = "{}/{}/{}_wt_peps_netmhc_output.txt".format(data_dir, 
#                                                               sample_name, 
#                                                               sample_name)
#        wt_calls = helper_funcs.read_netmhc_calls(wt_calls)
#
#        # organize lines for writing
#        organize_pairs = helper_funcs.organize_pairs(wt_calls, 
#                                                     mt_calls)
#
#        for i in organize_pairs:
#            i = [str(count)] + i + [hlas]
#            i = "\t".join(i)
#            to_write += [i]
#            count += 1
#
## write neoantigensStandardized to file
#prefix = "../../results/neo_files/"
#with open("{}/neoantigensStandardized.txt".format(prefix), "w") as f:
#    f.write("\n".join(to_write) + "\n")
#
## extract .fasta files
#fasta_dict = defaultdict(list)
#for sme in to_write[1:]:
#    sme = sme.split("\t")
#    id_num = sme[0]
#    mut_id = sme[1]
#    sample = sme[2]
#    wt_pep, mt_pep = sme[3], sme[4]
#    stuff = ">{}|WT|{}|{}\n{}\n>{}|MUT|{}|{}\n{}\n".format(sample, id_num, mut_id, wt_pep, 
#                                                           sample, id_num, mut_id, mt_pep)
#    fasta_dict[sample].append(stuff)
#
#for sample, data in fasta_dict.items():
#    with open("{}/neoantigens_{}.fasta".format(prefix, sample), "w") as f:
#        f.write("".join(data))
#
