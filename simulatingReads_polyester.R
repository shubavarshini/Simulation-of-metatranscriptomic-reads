library(polyester)
library(Biostrings)
library(tidyverse)

###Reading the transcript fasta file#####
txs <- readDNAStringSet("transcriptomicSequences.fasta.gz",format = "fasta")

###Reading the transcript count file#####
readspertx <- read.delim("transcriptCounts.txt",header=T,stringsAsFactors=F,sep="\t")

###Adding rows of the missing transcripts in the count table######
readspertx <- readspertx %>% add_row(Name=names(txs)[which(! names(txs) %in% readspertx$Name)])
####Replacing NAs with zero######
readspertx <- readspertx %>% mutate_if(is.numeric, ~replace(., is.na(.), 0))

####Converting the dataframe into a matrix####
mat_readspertx <- as.matrix(readspertx[,-1])
####Adding rownames and colnames as the loaded count dataframe####
rownames(mat_readspertx) <- readspertx[,1]
colnames(mat_readspertx) <- colnames(readspertx)[-1]

####simulating reads####
simulate_experiment_countmat(fasta="transcriptomicSequences.fasta.gz",readmat=mat_readspertx,outdir="./allTranscripts_simulation",
                             paired=T,readlen=75,seed=142,error_model='illumina5',gzip=TRUE)
