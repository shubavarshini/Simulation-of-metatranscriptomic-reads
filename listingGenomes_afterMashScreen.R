#!/usr/bin Rscript
library(tidyverse)
library(Biostrings)

###Usage:
#mashScreen_path=/vol/projects/salampal/data/microbiome_assembly/fermentedMilkStudyData
#Rscript listingGenomes_mashScreen.R ${mashScreen_path}/mashScreen_metatranscriptomics.tab ${mashScreen_path}/genomeSequences_mashScreen_metatranscriptomics

args <- commandArgs(trailingOnly = TRUE)
mashFile <- args[1]

mashFile <-read.delim(mashFile,header = F,sep = "\t",stringsAsFactors = F)
mashFile <- separate(mashFile, V2, into=c("kmers"), sep = "/", remove = T,convert = T, fill = "right")
mashFile_sorted <- subset(mashFile, mashFile$kmers >= 10 & mashFile$V4 < 0.001)
mashFile_sorted <- mashFile_sorted[order(mashFile_sorted$V1), ]

namesOfCloseSpecies <- mashFile_sorted$V5
genomeSequences <- DNAStringSet()

#Path types:
#1./vol/projects/salampal/data/microbiome_assembly/pangenomes/genomes/s__Zymomonas_mobilis/panaroo_results_default/pan_genome_reference.fa
#2./vol/projects/salampal/data/microbiome_assembly/pangenomes/genomes/s__Zymomonas_pomaceae/GCF_000218875.1_ASM21887v1_genomic/GCF_000218875.1_ASM21887v1_genomic.ffn
for (j in unique(unlist(namesOfCloseSpecies))) {
                path <- j
                fa <- readDNAStringSet(path, format = "fasta")
                #fa_seq <- DNAStringSet(paste(fa, collapse = "NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"))
                n <- gsub("/vol/projects/salampal/data/microbiome_assembly/pangenomes/genomes/","",j)
                n <- str_split(n,"/",n=2)[[1]][1]
                names(fa) <- gsub(" ","_",names(fa))
                names(fa) <- paste(n,"_",names(fa),sep="")
                genomeSequences <- c(genomeSequences, fa)
}

decoySeq <- readDNAStringSet("/vol/projects/salampal/data/wholeGenomes/GRCm38.primary_assembly.genome.fa.gz", format = "fasta")
#fa_seq <- DNAStringSet(paste(fa, collapse = "NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"))
decoyNames <- c(gsub(" ","_",names(decoySeq)))
names(decoySeq) <- decoyNames

genomeSequences <- c(genomeSequences,decoySeq)

writeXStringSet(genomeSequences, file = paste(args[2],".fa.gz", sep = ""), format = "fasta", compress = T)
writeLines(decoyNames, con  = paste(args[2],".decoy", sep = ""), sep = "\n")
