#!/usr/bin/bash

peptide_file=$1
hlas=$2
output_directory=$3

netmhc_path=/work/software/netMHC-3.4/netMHC

# file name without extension and path
peptide_file_name="${peptide_file%.*}"
peptide_file_name="${peptide_file_name##*/}"

$netmhc_path -a $hlas -l 9 $peptide_file > $output_directory/$peptide_file_name"_netmhc_output.txt"
