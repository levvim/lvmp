#!/usr/bin/bash
#bash-4.2$ ~/lvmp/lvmp/pipelines/mut_2c/scripts/filtering.sh /data/wolchok/PROJECT/2ctest_L6

module add singularity
module add python/3.6.4
module add java

# This script merged the MuTect output and creates region files for bam-readcount.

# input arguments
FILE=$1
SAMPLE=$2
bam_readcount=/data/wolchok/singularity/bam-readcount-0.7.4.simg
reference_genome=/data/wolchok/PROJECT/refs/GRCh37hg19/human_g1k_v37_decoy.fasta
filtermutations=/home/mangaril/lvmp/lvmp/pipelines/mut_2c/scripts/filter_mutations.py
snpeff_path=/home/mangaril/programs/snpEff/snpEff.jar

SAMPLE=${SAMPLE%%.*};
SAMPLE=${SAMPLE##*/}

echo $SAMPLE
echo $SAMPLE
echo $SAMPLE
## merge MuTect output
#cat $mutect_results_folder/mutect_stats*.txt | grep -v -e "#" -e "judgement" > $mutect_results_folder/mutect_stats.tmp
#
#mv $mutect_results_folder/mutect_stats.tmp $mutect_results_folder/mutect_stats.txt
#cp $mutect_results_folder/mutect_stats.txt $filtering_path/
#mutect_results=$filtering_path/mutect_stats.txt

################################################################################
# create mutect regions 
cd $FILE/muTect/
for i in "$SAMPLE".T.call_stats.txt; do echo $i; ifix=${i%%.*};ifix=${ifix##*/};
    cp $i "$FILE"/vcf/"$ifix".T.call_stats.txt
    cat "$i" | grep -v -e "#" -e "judgement" |\
        grep -v -e "#" -e "GL0" -e "NC_007605" -e "hs37d5" | \
        awk -v OFS='\t' '{ print $1, $2, $2 }' > "$FILE"/vcf/"$ifix".mutect_regions.txt
    sed -i '1d' "$FILE"/vcf/"$ifix".mutect_regions.txt
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

################################################################################
##calculate bam readcounts
cd $FILE/
for i in vcf/"$SAMPLE".merged_regions.txt; do echo $i; ifix=${i%%.*}; ifix=${ifix##*/};
    singularity exec --bind /data/wolchok/:/data/wolchok/ $bam_readcount \
        bam-readcount \
        -f $reference_genome \
        -l $i \
        -w 1 \
        bqsr/"$ifix".N.pp.bam \
        > vcf/"$ifix".normal_bam_readcount.txt
    singularity exec --bind /data/wolchok/:/data/wolchok/ $bam_readcount \
        bam-readcount \
        -f $reference_genome \
        -l $i \
        -w 1 \
        bqsr/"$ifix".T.pp.bam \
        > vcf/"$ifix".tumor_bam_readcount.txt
done

#################################################################################
# organize vcfs
# delete header lines from vcfs
cd $FILE/vcf/
for i in "$SAMPLE".mutect_regions.txt; do echo $i; ifix=${i%%.*}; ifix=${ifix##*/};
    sed -i -e '1,115d' "$ifix".passed.somatic.snvs.vcf
    sed -i -e '1,2d' "$ifix".T.call_stats.txt
done

cd $FILE/vcf
for i in "$SAMPLE".merged_regions.txt; do echo $i; ifix=${i%%.*}; ifix=${ifix##*/};
    python3 $filtermutations \
        "$ifix" \
        "$ifix".T.call_stats.txt \
        "$ifix".passed.somatic.snvs.vcf \
        "$ifix".normal_bam_readcount.txt \
        "$ifix".tumor_bam_readcount.txt \
        $FILE/vcf/
done
        
#################################################################################
#run snpeff
cd $FILE/vcf
for i in "$SAMPLE".merged_regions.txt; do echo $i; ifix=${i%%.*}; ifix=${ifix##*/};
    java -jar $snpeff_path ann \
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
        -fastaProt "$FILE"/vcf/"$fix".ann.fasta \
        GRCh37.75 \
        "$ifix".vcf > "$ifix".ann.vcf
done




























































































