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

readPath=/vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData/trimmedShuffedReads/metatranscriptomics
mashDB=/vol/projects/salampal/data/microbiome_assembly/pangenomes/panaroo_pangeomes_mash_k21_s10K.msh

zcat ${readPath}/*_trimmedShuffle_R*.fa.gz | mash screen -w -p 24 $mashDB - > /vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData/mashScreen_metatranscriptomics.tab

readPath=/vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData/trimmedShuffedReads/metagenomics
mashDB=/vol/projects/salampal/data/microbiome_assembly/pangenomes/panaroo_pangeomes_mash_k21_s10K.msh

zcat ${readPath}/*_trimmedShuffle_R*.fa.gz | mash screen -w -p 24 $mashDB - > /vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData/mashScreen_metagenomics.tab
zcat ${readPath}/*_genometrimmedShuffle_R*.fa.gz | mash screen -w -p 24 $mashDB - > /vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData/mashScreen_genomeSimulation_metagenomics.tab

mashScreen_path=/vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData

Rscript listingGenomes_mashScreen.R ${mashScreen_path}/mashScreen_metatranscriptomics.tab ${mashScreen_path}/genomeSequences_mashScreen_metatranscriptomics

Rscript listingGenomes_mashScreen.R ${mashScreen_path}/mashScreen_metagenomics.tab ${mashScreen_path}/genomeSequences_mashScreen_metagenomics
Rscript listingGenomes_mashScreen.R ${mashScreen_path}/mashScreen_genomeSimulation_metagenomics.tab ${mashScreen_path}/genomeSequences_mashScreen_genomeSimulation_metagenomics
