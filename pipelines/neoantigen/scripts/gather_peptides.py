#!/usr/bin/env python3

# This script gather the peptides from the annotations and writes to file.

# import packages
import os
import argparse
import json
# custom package
import gather_peptides_class

# parser
parser = argparse.ArgumentParser()
parser.add_argument("--vcf", "-v", help="annotated vcf")
parser.add_argument("--fastaprot", "-f", help="fastaprot output file")
parser.add_argument("--output_mt", "-m", help="output file")
parser.add_argument("--output_wt", "-w", help="output file")
args = parser.parse_args()

# initialize custom class
gather_peptides_class = gather_peptides_class.gather_peptides_class()

vcf = args.vcf
fasta = args.fastaprot

# check that there are protein-coding alterations
if os.path.isfile(fasta):
    wt_9mers, mt_9mers = gather_peptides_class.gather_peptides(vcf, fasta)

    if len(wt_9mers) != 0 and len(mt_9mers) != 0:

        # save to file
        with open("{}".format(args.output_wt), "w") as f:
            f.write("\n".join(wt_9mers) + "\n")
        with open("{}".format(args.output_mt), "w") as f:
            f.write("\n".join(mt_9mers) + "\n")
