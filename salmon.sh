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
#R1=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $17}')
#R2=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $18}')
R1=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $19}')
R2=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $20}')
outFileName=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $1}')
totReads=$(awk "NR == $SGE_TASK_ID" $IN_FILE | awk -F"," '{print $15}')
nReads=`echo $((totReads*2))`

genomeSequence_path=/vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData

salmon index -t ${genomeSequence_path}/genomeSequences_mashScreen_metatranscriptomics.fa.gz --decoy ${genomeSequence_path}/genomeSequences_mashScreen_metatranscriptomics.decoy -p 24 -i ${genomeSequence_path}/genomeSequences_mashScreen_metatranscriptomics_salmonIndex

salmon index -t ${genomeSequence_path}/genomeSequences_mashScreen_metagenomics.fa.gz --decoy ${genomeSequence_path}/genomeSequences_mashScreen_metagenomics.decoy -p 24 -i ${genomeSequence_path}/genomeSequences_mashScreen_metagenomics_salmonIndex

path=/vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData

if [ "${seqType}" == "TRANSCRIPTOMIC" ]
then
       salmon quant -i ${path}/genomeSequences_mashScreen_metatranscriptomics_salmonIndex -l A -1 ${path}/trimmedShuffedReads/metatranscriptomics/${outFileName}_trimmedShuffle_R1.fa.gz -2 ${path}/trimmedShuffedReads/metatranscriptomics/${outFileName}_trimmedShuffle_R2.fa.gz -p 10 --meta --validateMappings --gcBias -o ${path}/trimmedShuffedReads/metatranscriptomics/${outFileName}_${time}_salmonQuant
else
      salmon quant -i ${path}/genomeSequences_mashScreen_metagenomics_salmonIndex -l A -1 ${path}/trimmedShuffedReads/metagenomics/${outFileName}_trimmedShuffle_R1.fa.gz -2 ${path}/trimmedShuffedReads/metagenomics/${outFileName}_trimmedShuffle_R2.fa.gz -p 10 --meta --validateMappings --gcBias -o ${path}/trimmedShuffedReads/metagenomics/${outFileName}_${time}_salmonQuant
     
fi
