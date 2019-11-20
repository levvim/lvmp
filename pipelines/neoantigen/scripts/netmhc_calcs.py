#!/usr/bin/env python3

# This script runs netmhc calculations.

# import packages
import argparse
import subprocess

# input
parser = argparse.ArgumentParser()
parser.add_argument("subject", help="subject")
parser.add_argument("peptide_file", help="file containing peptides")
parser.add_argument("hla_file", help="file containing the patient HLA types")
parser.add_argument("allowed_hlas", help="allowed HLAs in NetMHC 3.4")
parser.add_argument("dispatcher_path", help="path to dispatcher script")
parser.add_argument("job_files_outdir", help="job files output path")
parser.add_argument("output_directory", help="output path")
args = parser.parse_args()
subject = args.subject
peptide_file = args.peptide_file
hla_file = args.hla_file
allowed_hlas = args.allowed_hlas
dispatcher_path = args.dispatcher_path
job_files_outdir = args.job_files_outdir
output_directory = args.output_directory

# HLA stuff

# allowed HLAs
with open(allowed_hlas, "r") as f:
    allowed_hla_types = [l.strip("\n") for l in f.readlines()]

# read in the subject HLA types
with open(hla_file, "r") as h_f:
    hla_lines = [l.strip("\n").split("\t") for l in h_f.readlines()]

# hla dictionary for all patients in cohort
hla_dict = {}
for line in hla_lines:
    name = line[0]
    hlas = line[1].split(",")
    hlas = [h for h in hlas if h in allowed_hla_types]
    if hlas != []:
        hlas = ",".join(hlas)
        hla_dict[name] = hlas
    else:
        with open("./samples_no_available_hlas.txt", "r") as f:
            no_avail_hlas_samples = [l.strip("\n") for l in f.readlines()]
        if name not in no_avail_hlas_samples:
            with open("./samples_no_available_hlas.txt", "a") as f:
                f.write("{}\n".format(name))

# subject HLAs
hlas = hla_dict[subject]

# run NetMHC 3.4
#command = ["bash", dispatcher_path, peptide_file, hlas, output_directory]
command = ["qsub", "-V", "-cwd",# "-q", "standard.q", 
           "-o", job_files_outdir, "-e", job_files_outdir, 
           dispatcher_path, peptide_file, hlas, output_directory]
subprocess.call(command)
