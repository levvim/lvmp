#!/usr/bin/bash
#bash-4.2$ ~/lvmp/lvmp/pipelines/mut_2c/scripts/filtering_aws.sh

################################################################################
# Project Config
# input arguments
#FILE=$1
#SAMPLE=$2
#bam_readcount=/data/wolchok/singularity/bam-readcount-0.7.4.simg
#reference_genome=/data/wolchok/PROJECT/refs/GRCh37hg19/human_g1k_v37_decoy.fasta
#filtermutations=/home/mangaril/lvmp/lvmp/pipelines/mut_2c/scripts/filter_mutations.py
#snpeff_path=/data/wolchok/singularity/snpeff-4.3t.simg

## merge MuTect output 
#cat $mutect_results_folder/mutect_stats*.txt | grep -v -e "#" -e "judgement" > $mutect_results_folder/mutect_stats.tmp

#getopts for argument input
usage() { echo -en "LVMP v1.1 EC2 setup \nExample: lvmp_ec2 \n\t-p /home/ec2-user/PROJECT1/ \n\t-s Sample1 \n\t-b /home/ec2-user/CONTAINER/bam-readcount.simg \n\t-r /home/ec2-user/refs/ucsc.hg19.fasta \n\t-f /home/ec2-user/scripts/filter_mutations.py \n\t-e /home/ec2-user/CONTAINER/snpeff-4.3t.simg\n\nFlags:\n" && grep " .)\ #" $0; exit 0; } 
[ $# -eq 0 ] && usage
#while getopts ":h:k:s:c:" arg; do
while getopts ":h:p:s:b:r:f:e:" arg; do
    case $arg in
        p) #Project dir
            FILE=${OPTARG}
            ;;
        s) #Sample ID
            SAMPLE=${OPTARG}
            ;;
        b) #bam-readcount Container
            bam_readcount=${OPTARG}
            ;;
        r) #reference genome
            reference_genome=${OPTARG}
            ;;
        f) #filter_mutations.py script
            filtermutations=${OPTARG}
            ;;
        e) #path to snpeff
            snpeff=${OPTARG}
            ;;
        h | *) # Display help.
        usage
            exit 0
            ;;
    esac
done

SAMPLE=${SAMPLE%%.*};
SAMPLE=${SAMPLE##*/}
echo $SAMPLE
################################################################################
#create mutect regions 
cd "$FILE"/muTect/
for i in "$SAMPLE".T.call_stats.txt; do echo $i; ifix=${i%%.*};ifix=${ifix##*/};
    cp $i "$FILE"/vcf/"$ifix".T.call_stats.txt
    cat "$i" | grep -v -e "#" -e "judgement" |\
        grep -v -e "#" -e "GL0" -e "NC_007605" -e "hs37d5" | \
        awk -v OFS="\t" '{ print $1, $2, $2 }' > "$FILE"/vcf/"$ifix".mutect_regions.txt
    sed -i "1d" "$FILE"/vcf/"$ifix".mutect_regions.txt
done

# rename and organize strelka output into vcf folder
cd $FILE/strelka/
for i in "$SAMPLE".T; do echo $i; ifix=${i%%.*}; echo $ifix; 
    cd "$FILE"/strelka/"$i"/results; 
    for ii in *.vcf; do 
        cp "$ii" "$FILE"/vcf/"$ifix"."$ii"
    done
done

# create strelka regions
cd $FILE/vcf/
for i in "$SAMPLE".passed.somatic.snvs.vcf; do echo $i; ifix=${i%%.*}; ifix=${ifix##*/};
    cat $i | grep -v -e "#" -e "GL0" -e "NC_007605" -e "hs37d5" | \
        awk -v OFS='\t' '{ print $1, $2, $2 }' > "$FILE"/vcf/"$ifix".strelka_regions.txt
done

# cat strelka and mutect regions together
cd $FILE/vcf/
for i in "$SAMPLE".mutect_regions.txt; do echo $i; ifix=${i%%.*}; ifix=${ifix##*/};
    cat "$FILE"/vcf/"$ifix".mutect_regions.txt  "$FILE"/vcf/"$ifix".strelka_regions.txt | \
        sort -k 1 -n | uniq > "$FILE"/vcf/"$ifix".merged_regions.txt
done

#################################################################################
##calculate bam readcounts
cd $FILE/
for i in vcf/"$SAMPLE".merged_regions.txt; do echo $i; ifix=${i%%.*}; ifix=${ifix##*/};
    singularity exec --bind $FILE:$FILE $bam_readcount \
        bam-readcount \
        -f $reference_genome \
        -l $i \
        -w 1 \
        bqsr/"$ifix".N.pp.bam \
        > vcf/"$ifix".normal_bam_readcount.txt
    singularity exec --bind $FILE:$FILE $bam_readcount \
        bam-readcount \
        -f $reference_genome \
        -l $i \
        -w 1 \
        bqsr/"$ifix".T.pp.bam \
        > vcf/"$ifix".tumor_bam_readcount.txt
done

#################################################################################
 organize vcfs
 delete header lines from vcfs
cd $FILE/vcf/
for i in "$SAMPLE".mutect_regions.txt; do echo $i; ifix=${i%%.*}; ifix=${ifix##*/};
    sed -i -e "1,115d" "$ifix".passed.somatic.snvs.vcf
    sed -i -e "1,2d" "$ifix".T.call_stats.txt
done

cd $FILE/vcf
for i in "$SAMPLE".merged_regions.txt; do echo $i; ifix=${i%%.*}; ifix=${ifix##*/};
	singularity exec --bind $FILE:$FILE $snpeff bash -c "
	    python3 \"$filtermutations\" \
	        \"$ifix\" \
	        \"$ifix\".T.call_stats.txt \
	        \"$ifix\".passed.somatic.snvs.vcf \
	        \"$ifix\".normal_bam_readcount.txt \
	        \"$ifix\".tumor_bam_readcount.txt \
	        \"$FILE\"/vcf/;"
done

        
##################################################################################
#run snpeff
cd $FILE/vcf
for i in "$SAMPLE".merged_regions.txt; do echo $i; ifix="${i%%.*}"; ifix="${ifix##*/}";
singularity exec --bind $FILE:$FILE $snpeff bash -c "
    java -jar /snpEff/snpEff.jar ann \
        -noStats \
        -strict \
        -no-downstream \
        -no-intergenic \
        -no-intron \
        -no-upstream \
        -no-utr \
        -hgvs1LetterAa \
        -hgvs \
        -canon \
        -v \
        -onlyProtein \
        -fastaProt \"$FILE\"/vcf/\"$fix\".ann.fasta \
        GRCh37.75 \
        \"$ifix\".vcf > \"$ifix\".ann.vcf;"
done


################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
