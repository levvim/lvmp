#levim wolchok lab 2016
#generate read group information from illumina Fastq header files in a folder to add in BAM read group information
#check to see fastq files have no header information
#barcode taken from filename, may need to change barcode var to choose correct field

#sample FASTQ header file:
#@GWZHISEQ01:443:HFWHWBCXX:1:1101:1209:2082 1:N:0:AAACATCG
#sample output for use in Picard AddOrReplaceReadGroups (https://www.broadinstitute.org/gatk/guide/article?id=6472)
#or bwamem -R read group addition flag
#@RG ID:H0164.2  PL:illumina PU:H0164ALXX140820.2    LB:Solexa-272222    PI:0    DT:2014-08-20T00:00:00-0400 SM:NA12878  CN:BI

################################################################################
##to generate readgroup files in a folder of fastq for RG args in bwa (add readgroups during alignment)
##dir of fastq files
#FILE=$HOME/../../projects/advaxis/fastq/
#
#cd $FILE
#for file in *.fastq; do \
#    echo 'formatting readgroups for' "$file"
#    barcode=$(echo $file | cut -f 2 -d'_')
#
#    header=$(sed -n '1p' "$file") #add first line of fastq file to variable (header of the first read IF there is no fastq header information)
#
#    ID=$(echo "$header" | cut -f 3,4 -d':' --output-delimiter='.')
#    lane=$(echo "$header" | cut -f 4 -d':' --output-delimiter='.'); flowcell=$(echo "$header" | cut -f 3 -d':' --output-delimiter='.');
#    PU=$(echo $flowcell$barcode.$lane) #add barcode from end of file
#    SM=$(echo $file | cut -f 1 -d'_')
#    LB=$(echo $header | cut -f 1 -d':' | cut -c 2-)
#    
#    printf "\"@RG ID:%s\tPL:%s\tPU:%s\tLB:%s\tSM:%s\"" "$ID" "$PL" "$PU" "$LB" "$SM" > "$file".readgroup
#done
#
#file=$1 #assign file args to script variable
#    echo 'formatting readgroups for' "$file"
#
##sequencing platform: 
#export PL=illumina
##export    barcode=$(echo $file | cut -f 2 -d'_') #use when the barcode is in the filename (i.e. IGO nomenclature, after the first underscore)
#export    header=$(sed -n '1p' "$file") #add first line of fastq file to variable (header of the first read IF there is no fastq header information)
#
#export    barcode=$(echo "$header" | cut -f 10 -d':' --output-delimiter='.')
#
#export    ID=$(echo "$header" | cut -f 3,4 -d':' --output-delimiter='.')
#export    lane=$(echo "$header" | cut -f 4 -d':' --output-delimiter='.'); export flowcell=$(echo "$header" | cut -f 3 -d':' --output-delimiter='.');
#export    PU=$(echo $flowcell$barcode.$lane) #add barcode from end of file
#export    SM=$(echo $file | cut -f 1 -d'_')
#export    LB=$(echo $header | cut -f 1 -d':' | cut -c 2-)



#workflow: get rg files from raw bams first then move into appropriate folders:
#for i in *.bam; do RGfromBam.sh $i; done
#mv *.rg.txt ../fastq/
################################################################################
#write to file instead
file=$1 #assign file args to script variable
    echo 'formatting readgroups for' "$file"

output=$2


sample=${file%.bam}; 
sample=${sample##*/}; 

echo "$(samtools view -H "$file" | grep "@RG" )" > "$file".rg.txt

i=1
while read line; do
    line="$(echo "$line" | sed 's/\t/\\t/g')"
    echo $line > "$sample".L"$i".01.fastq.rg.txt
    i=$((i+1))

done < "$file".rg.txt


