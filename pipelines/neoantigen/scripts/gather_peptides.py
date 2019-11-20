#!/usr/bin/env python3

# This script gather the peptides from the annotations and writes to file.

# import packages
import os
# custom package
import gather_peptides_class

# initialize custom class
gather_peptides_class = gather_peptides_class.gather_peptides_class()

# annotated vcf directory
ann_dir = "../../results/vcf_annotation/"

for sample in os.listdir(ann_dir):
    vcf = "{}/{}/{}_ann.vcf".format(ann_dir, sample, sample)
    fasta = "{}{}/{}.fasta".format(ann_dir, sample, sample)

    # check that there are protein-coding alterations
    if os.path.isfile(fasta):
        wt_9mers, mt_9mers = gather_peptides_class.gather_peptides(vcf, fasta)

        if len(wt_9mers) != 0 and len(mt_9mers) != 0:

            # save to file
            output_dir = "../../results/peptide_extraction/{}/".format(sample)
            os.mkdir(output_dir)
            with open("{}/{}_wt_peps.txt".format(output_dir, sample), "w") as f:
                f.write("\n".join(wt_9mers) + "\n")
            with open("{}/{}_mt_peps.txt".format(output_dir, sample), "w") as f:
                f.write("\n".join(mt_9mers) + "\n")
