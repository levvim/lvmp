#!/usr/bin/bash

# This script runs netmhc.
#getopts for argument input
usage() { echo "$0: run netMHC. flags:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts ":hl:a:d:j:o:p:" arg; do
    case $arg in
        l) #HLA file
            HLA=${OPTARG}
            ;;
        a) #allowed HLAs
            HLA_ALLOW=${OPTARG}
            ;;
        d) #dispatcher script
            DISPATCHER=${OPTARG}
            ;;
        j) #job output dir
            JOB_OUTPUT=${OPTARG}
            ;;
        o) #output dir
            OUTPUT_DIR=${OPTARG}
            ;;
        p) #peptide dir
            PEPTIDE_DIR=${OPTARG}
            ;;
        h | *) # Display help.
            usage
            exit 0
            ;;
    esac
done

#hla_file="../../data/hlas.txt"
#allowed_hlas="./allowed_HLA_netMHC3.4.txt"
#dispatcher_path="./dispatcher.sh"
#job_output_files="./job_output_files/"
#output_dir="../../results/netmhc_calls/"
#peptide_dir="../../results/peptide_extraction/"

# remove samples with hla issues in case it is there, since the script writes this 
# and append to it as it goes through the samples
rm -f "$PEPTIDE_DIR/samples_no_available_hlas.txt"
touch "$PEPTIDE_DIR/samples_no_available_hlas.txt"

# only do neoantigen calling for samples with hlas and peptides

IFS=$'\n'

# subject name
name="$(echo "$i" | cut -d $'\t' -f 1)"
echo 'name'
echo $name

# go through all peptide directories with the name
for j in $(ls $PEPTIDE_DIR | grep -- "$name")
do
    echo $j
    output_path="$OUTPUT_DIR"/"$j"/
    mkdir 'output_path'
    mkdir $output_path
    
    for k in "$j""_mt_peps.txt" "$j""_wt_peps.txt"
    do
        python3 netmhc_calcs.py \
            "$name" \
            "$peptide_dir"/"$j"/"$k" \
            "$hla_file" \
            "$allowed_hlas" \
            "$dispatcher_path" \
            "$job_output_files" \
            "$output_path"
    done
done

python3 netmhc_calcs.py \
    "$name" \
    "$peptide_dir"/"$j"/"$k" \
    "$hla_file" \
    "$allowed_hlas" \
    "$dispatcher_path" \
    "$job_output_files" \
    "$output_path"



#################################################################################
##!/usr/bin/bash
#
## This script runs netmhc.
#
#hla_file="../../data/hlas.txt"
#allowed_hlas="./allowed_HLA_netMHC3.4.txt"
#dispatcher_path="./dispatcher.sh"
#job_output_files="./job_output_files/"
#output_dir="../../results/netmhc_calls/"
#peptide_dir="../../results/peptide_extraction/"
#
## remove samples with hla issues in case it is there, since the script writes this 
## and append to it as it goes through the samples
#rm "./samples_no_available_hlas.txt"
#touch "./samples_no_available_hlas.txt"
#
## only do neoantigen calling for samples with hlas and peptides
#
#IFS=$'\n'
#
#for i in $(cat $hla_file)
#do
#    # subject name
#    name="$(echo "$i" | cut -d $'\t' -f 1)"
#
#    # go through all peptide directories with the name
#    for j in $(ls $peptide_dir | grep -- "$name")
#    do
#        output_path="$output_dir"/"$j"/
#        mkdir $output_path
#        
#        for k in "$j""_mt_peps.txt" "$j""_wt_peps.txt"
#        do
#            python3 netmhc_calcs.py \
#                "$name" \
#                "$peptide_dir"/"$j"/"$k" \
#                "$hla_file" \
#                "$allowed_hlas" \
#                "$dispatcher_path" \
#                "$job_output_files" \
#                "$output_path"
#        done
#    done
#done
#################################################################################
