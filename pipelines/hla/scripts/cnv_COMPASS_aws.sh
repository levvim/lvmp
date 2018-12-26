# levim wolchok lab 2018
# lvmp dependency setup for ec2
#
# To use in a aws instance:
#   i=sample ID
#
#   curl https://raw.githubusercontent.com/levvim/lvmp/master/pipelines/hla//scripts/cnv_COMPASS_aws.sh > $HOME/cnv_COMPASS_aws.sh 
#
#   aws configure set aws_access_key_id AKIAJWEETMCKYNICPXZA                                                     
#   aws configure set aws_secret_access_key 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                             
#   aws configure set default.region us-east-1                                                                   
#
#   aws s3 cp $m $HOME/mut_2c_metadata.csv                                                                       
#   aws s3 cp $s $HOME/mut_2c_samples.csv                                                                        
#
#   chmod u+x $HOME/cnv_COMPASS_aws.sh 
#   $HOME/cnv_COMPASS_aws.sh  -s SAMPLEID
#
################################################################################
# Project Config

#getopts for argument input
usage() { echo -en "CNV calling from SRA on aws. \nExample: cnv_COMPASS_aws.sh \n\t-s sample ID\nFlags:\n" && grep " .)\ #" $0; exit 0; } 
[ $# -eq 0 ] && usage
while getopts ":hs:" arg; do
    case $arg in
        s) #Sample ID
            SAMPLE=${OPTARG}
            ;;
        h | *) # Display help.
        usage
            exit 0
            ;;
    esac
done

################################################################################
# Metadata
#MD_AWSKEY="$(cat $SAMPLE | awk -F, 'NR == 1 { print $2 }' )"
#MD_SECRETKEY="$(cat $SAMPLE | awk -F, 'NR == 2 { print $2 }' )"
#MD_DEFAULTREGION="$(cat $SAMPLE | awk -F, 'NR == 3 { print $2 }' )"
USER=ec2-user

#################################################################################
# Set aws key
#aws configure set aws_access_key_id $MD_AWSKEY
#aws configure set aws_secret_access_key $MD_SECRETKEY
#aws configure set default.region $MD_DEFAULTREGION

################################################################################
# Update system and install pipeline program dependencies
sudo yum update -y
sudo yum install docker -y
sudo yum install squashfs-tools -y
sudo yum install git python -y
sudo yum update -y && \
           sudo yum groupinstall 'Development Tools' -y && \
           sudo yum install libarchive-devel -y

## docker (post install instructions)
#sudo groupadd docker
#sudo usermod -aG docker $(whoami)
#sudo service docker startsudo service 

sudo amazon-linux-extras install docker -y 
sudo service docker start
sudo usermod -a -G docker $USER

## singularity 2.5.2
sudo wget https://github.com/singularityware/singularity/releases/download/2.5.2/singularity-2.5.2.tar.gz
sudo tar -xzvf singularity-2.5.2.tar.gz 
cd singularity-2.5.2
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install
cd ..
################################################################################
cd /home/ec2-user/
wget ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-centos_linux64.tar.gz
tar -xzf sratoolkit.current-centos_linux64.tar.gz
/home/ec2-user/sratoolkit.2.9.2-centos_linux64/bin/vdb-config --import /home/ec2-user/prj_16485.ngc
aws s3 cp s3://immunoseqvault/COMPUTE/SRA/Alex/prj_16485.ngc /home/ec2-user/prj_16485.ngc
#cd /home/ec2-user/ncbi/dbGaP-16485; /home/ec2-user/sratoolkit.2.9.2-centos_linux64/bin/sam-dump SRR2128193 > SRR2128193.sam

################################################################################
## Configure project folders and samples
cd /home/
mkdir -p /home/"$USER"/PROJECT/
mkdir -p /home/"$USER"/SCRIPTS/
mkdir -p /home/"$USER"/CONTAINERS/
mkdir -p /home/"$USER"/REFS/
mkdir -p /home/"$USER"/OUTPUT/

mkdir -p /home/"$USER"/PROJECT/sam/
mkdir -p /home/"$USER"/PROJECT/bam/
mkdir -p /home/"$USER"/PROJECT/facets/

PROJECT="/home/$USER/PROJECT/"
SCRIPTS="/home/$USER/SCRIPTS/"
CONTAINERS="/home/$USER/CONTAINERS/"
REFS="/home/$USER/REFS/"
OUTPUT="/home/$USER/OUTPUT/"

# Copy in pipeline dependencies
aws s3 cp s3://immunoseqvault/COMPUTE/Exomeseq/Refs/GRCh37hg19/dbsnp_138.b37.vcf "$REFS"/dbsnp_138.b37.vcf 
aws s3 cp s3://immunoseqvault/COMPUTE/Exomeseq/Images/samtools-1.6.simg "$CONTAINERS"/samtools-1.6.simg
aws s3 cp s3://immunoseqvault/COMPUTE/Exomeseq/Images/run_facets.R "$SCRIPTS"/run_facets.R

aws s3 cp s3://immunoseqexternal/Collab_BG/COMPASS/sampletable_compass.csv /home/sampletable_compass.csv
sed -i 's/\r$//' $HOME/sampletable_compass.csv  

################################################################################
################################################################################
# Determine matching IDs for normal and tumor samples using ID table
NORMALID="$(grep $SAMPLE $HOME/sampletable_compass.csv | head -n 1 | cut -d',' -f 2)"
TUMORID="$(grep $SAMPLE $HOME/sampletable_compass.csv | head -n 1 | cut -d',' -f 3)"

## dl_sam_normal
echo "downloading normal $SAMPLE"
cd /home/ec2-user/ncbi/dbGaP-16485;
/home/ec2-user/sratoolkit.2.9.2-centos_linux64/bin/sam-dump.2.9.2 $NORMALID > $PROJECT/sam/"$SAMPLE".N.sam; 

## dl_sam_tumor
echo "downloading tumor $SAMPLE"
cd /home/ec2-user/ncbi/dbGaP-16485;
/home/ec2-user/sratoolkit.2.9.2-centos_linux64/bin/sam-dump.2.9.2 $TUMORID > $PROJECT/sam/"$SAMPLE".T.sam; 

## samtobam
singularity exec --bind $PROJECT:$PROJECT --bind $REFS:$REFS $CONTAINERS/samtools-1.6.simg \
samtools view -bh $PROJECT/sam/"$SAMPLE".N.sam  > $PROJECT/bam/"$SAMPLE".N.bam ; 

singularity exec --bind $PROJECT:$PROJECT --bind $REFS:$REFS $CONTAINERS/samtools-1.6.simg \
samtools view -bh $PROJECT/sam/"$SAMPLE".T.sam  > $PROJECT/bam/"$SAMPLE".T.bam ; 

#rm $PROJECT/sam/"$SAMPLE".T.sam 
#rm $PROJECT/sam/"$SAMPLE".N.sam 

## index_sam
singularity exec --bind $PROJECT:$PROJECT --bind $REFS:$REFS $CONTAINERS/samtools-1.6.simg \
samtools index $PROJECT/bam/"$SAMPLE".T.bam  

singularity exec --bind $PROJECT:$PROJECT --bind $REFS:$REFS $CONTAINERS/samtools-1.6.simg \
samtools index $PROJECT/bam/"$SAMPLE".N.bam  

## snp_pileup
singularity exec --bind $PROJECT:$PROJECT --bind $REFS:$REFS $CONTAINERS/facets_latest.sif \
snp-pileup                          \       
    --gzip -q15 -Q20 -P100 -r25,0   \
    "$REFS"/dbsnp_138.b37.vcf       \ 
    $PROJECT/facets/"$SAMPLE".csv.gz\
    $PROJECT/bam/"$SAMPLE".N.bam    \
    $PROJECT/bam/"$SAMPLE".T.bam  

## facets
singularity exec --bind $PROJECT:$PROJECT --bind $REFS:$REFS $CONTAINERS/facets_latest.sif \
Rscript $SCRIPTS/run_facets.R                   \
$SAMPLE                                         \
$PROJECT/facets/"$SAMPLE".csv.gz                \
$PROJECT/facets/                                \
$PROJECT/facets/"$SAMPLE"_facets_output.txt                  

################################################################################
# Transfer relevant output files back to s3
aws s3 cp $PROJECT/facets/"$SAMPLE".csv.gz s3://immunoseqexternal/Collab_BG/COMPASS/WES/CNV/"$SAMPLE".csv.gz 
aws s3 cp $PROJECT/facets/"$SAMPLE"_facets_output.txt s3://immunoseqexternal/Collab_BG/COMPASS/WES/CNV/"$SAMPLE"_facets_output.csv.gz 
























































































