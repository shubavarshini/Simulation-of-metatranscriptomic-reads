#!/bin/bash

#$ -V
#$ -N fmpSal
#$ -l arch=linux-x64
#$ -l vf=10G
#$ -pe multislot 24
#$ -b n
#$ -q all.q
#$ -i /dev/null
#$ -e /vol/cluster-data/salampal/sge_logs/
#$ -o /vol/cluster-data/salampal/sge_logs/
#$ -t 2:31
#$ -tc 10
#$ -cwd

unset PYTHONPATH


IN_FILE=/vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData/dataDownloadedDetails_fastqPaths.csv
readsPath=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $14}')
seqType=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $8}')
time=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $13}')
R1=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $17}')
R2=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $18}')
outFileName=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $1}')
totReads=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $15}')
nReads=`echo $((totReads*2))`

############Trimming and Shuffling using BBMap tools##############

trimmedReads=/vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData/trimmedShuffedReads/metagenomics

~/Softwares/bbmap/bbduk.sh in=$R1 in2=$R2 out=${trimmedReads}/${outFileName}_trimmed_R1.fa.gz out2=${trimmedReads}/${outFileName}_trimmed_R2.fa.gz ref=~/Softwares/bbmap/resources/adapters.fa ktrim=r k=23 mink=11 hdist=1 tpe tbo 
~/Softwares/bbmap/shuffle.sh -Xmx100g overwrite=true in=${trimmedReads}/${outFileName}_trimmed_R1.fa.gz in2=${trimmedReads}/${outFileName}_trimmed_R2.fa.gz out=${trimmedReads}/${outFileName}_trimmedShuffle_R1.fa.gz out2=${trimmedReads}/${outFileName}_trimmedShuffle_R2.fa.gz -Xmx100g

