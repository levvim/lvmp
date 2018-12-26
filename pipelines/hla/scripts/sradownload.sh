
i=$1

SAMPLE="$(grep $i /data/wolchok/PROJECT/compass_cnv/sampletable_compass.csv | head -n 1 | cut -d',' -f3)"; 

echo $SAMPLE; 
echo $SAMPLE; 

cd /lila/data/wolchok/PROJECT/compass_hla/sam; 

set -x
/lila/data/wolchok/PROJECT/compass_hla/PROGRAMS/sratoolkit.2.9.2-centos_linux64/bin/sam-dump.2.9.2 $SAMPLE > $2

