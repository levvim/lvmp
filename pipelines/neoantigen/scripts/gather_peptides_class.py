#!/usr/bin/env python3

# This class contains functions to gather peptides from annotations.

# import packages
from Bio import SeqIO
from Bio.SeqUtils import IUPACData
from collections import defaultdict
import re

# class
class gather_peptides_class(object):
    '''
    This class contains functions to gather peptides from annotations.
    '''

    def __init__(self):
        '''
        Constructor.
        '''
        return

    def gather_peptides(self, vcf, fasta):
        '''
        This script parses a paired vcf and fasta for missense mutations.
        '''
        # read in vcf
        with open(vcf, "r") as f:
            vcf_lines = [l.strip("\n").split("\t") for l in f.readlines() if l[0] != "#"]

        # sample name
        sample_name = vcf.split("/")[-1].split(".")[0].replace(".ann", "")

        # go through the annotated lines and save missense mutations on which to discover peptides
        missense_mutations = []
        for line in vcf_lines:
            # mutation information
            mut_id = line[2]
            mut_id_no_name = "_".join(mut_id.split("_")[:-1])
            _, _, ref, alt = mut_id_no_name.split("_")

            # check that it is only an SNV that causes a missense mutation
            if len(ref) == len(alt) == 1:

                # our annotations
                info = line[7]
                all_annotations = info.split(";")[1].replace("ANN=", "").split(",")
                all_annotations = [ann for ann in all_annotations if \
                                   "missense_variant" in ann.split("|")[1] and \
                                   "WARNING" not in ann.split("|")[-1] and \
                                   "ERROR" not in ann.split("|")[-1]]

                # check that we got a missense variant without issues at all
                if all_annotations != []:
                    for ann in all_annotations:
                        gene = ann.split("|")[4]
                        aa_mut = ann.split("|")[10]
                        #aa_pos = aa_mut[5:-3]
                        #ref_aa = IUPACData.protein_letters_3to1[aa_mut[2:5]]
                        #alt_aa = IUPACData.protein_letters_3to1[aa_mut[-3:]]
                        #aa_mut = "p.{}{}{}".format(ref_aa, aa_pos, alt_aa)
                        transcript_id = ann.split("|")[6]
                        mut = (mut_id_no_name, transcript_id)
                        missense_mutations.append(mut)

        # gather peptides from transcripts in the fasta file

        # the peptide count for each mutation
        # (one mutation may have more than 9 mutant peptides)
        pep_count_dict = defaultdict(int)

        # containers for the WT and MT 9-mers
        wt_9mers, mt_9mers = [], []

        # read in the protein sequences (reference and alternate)
        prot_seqs = list(SeqIO.parse(fasta, "fasta"))
        ref_seqs = prot_seqs[0::2]
        alt_seqs = prot_seqs[1::2]

        # go through pairs of reference and alternate sequences
        for r_seq, a_seq in zip(ref_seqs, alt_seqs):

            # amino acid sequences
            r_seq_aa = r_seq.seq
            a_seq_aa = a_seq.seq

            # mutation information from the fasta file
            desc = a_seq.description.split()
            chrom = desc[2].split(":")[0]
            pos_1 = desc[2].split(":")[1].split("-")[0]
            pos_2 = desc[2].split(":")[1].split("-")[1]
            ref_base = desc[3].split(":")[1]
            alt_base = desc[4].split(":")[1]
            aa_mut = desc[5].split(":")[1]
            transcript_id = desc[0]

            # mutation from fasta file (without the name)
            mut_id = "_".join([chrom, pos_1, ref_base, alt_base])#, sample_name])

            # check if in considered missense mutations
            if (mut_id, transcript_id) in missense_mutations:
                # some basic checks
                if (pos_1 == pos_2 # check that DNA mutation in one position
                    and ref_base != alt_base # check that ref and alt bases different
                    and aa_mut != "" # check that the amino acid change is nonsynonymous
                    and "*" not in aa_mut # check that the mutation is not a stop codon mutation
                    and "?" not in aa_mut): # check that all amino acids are known in the mutation

                    # amino acid mutation information
                    # position in python
                    # for nucleotide nomenclature
                    #mut_pos = int(aa_mut[5:-3]) - 1
                    #ref_aa = IUPACData.protein_letters_3to1[aa_mut[2:5]]
                    #alt_aa = IUPACData.protein_letters_3to1[aa_mut[-3:]]
                    #ref_aa = aa_mut[2]
                    #alt_aa = aa_mut[6]

                    # for aa nomenclature
                    m=re.split('(\d+)',aa_mut)
                    mut_pos=int(m[1])
                    ref_aa=m[0][2]
                    alt_aa=m[2]

                    # check that it is a missense mutation
                    if ref_aa != alt_aa:

                        # find the 9-mers and do checking
                        for i in range(9):
                            wt_pep = r_seq_aa[mut_pos - 8 + i : mut_pos + 1 + i]
                            mt_pep = a_seq_aa[mut_pos - 8 + i : mut_pos + 1 + i]

                            # do some checks
                            if (len(wt_pep) == len(mt_pep) == 9 and 
                                wt_pep != mt_pep and 
                                "*" not in wt_pep and "*" not in mt_pep and 
                                "?" not in wt_pep and "?" not in mt_pep and 
                                "U" not in wt_pep and "U" not in mt_pep):

                                pep_count = pep_count_dict[mut_id]
                                wt_9mers.append(">{}_{}_{}".format(mut_id, sample_name, pep_count))
                                wt_9mers.append(str(wt_pep))
                                mt_9mers.append(">{}_{}_{}".format(mut_id, sample_name, pep_count))
                                mt_9mers.append(str(mt_pep))
                                pep_count_dict[mut_id] += 1

        return wt_9mers, mt_9mers
