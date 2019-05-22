#!/usr/bin/Rscript
##########
library(tidyverse)

#Sample selection #####
args <- commandArgs(trailingOnly=TRUE)
print(args)
# trailingOnly=TRUE means that only your arguments are returned
Sample <- args[1]
Sample
beds_folder <- args[2]
beds_folder
outDir <- args[3]
outDir
sPath <- paste0(beds_folder, "/", Sample, "/")
outFolder <- paste0(outDir, "/", Sample)
dir.create(outFolder, showWarnings = F, recursive = T)
#####

input <- read.delim(paste0(sPath, Sample, "_intersect.bed"), header = F)

colnames(input) <- c("Chr", "Start_read", "End_read", "Strand", "Start_CDS", "End_CDS", "ID", "Overlap")

input_plus <- subset(input, Strand == "+")
input_minus <- subset(input, Strand == "-")

input_plus <- input_plus[, c(1,2,5,6,7)]
input_plus$Dist_start <- input_plus$Start_read - input_plus$Start_CDS
input_plus$Dist_end <- input_plus$Start_read - input_plus$End_CDS
input_plus <- input_plus[, c(1,5,6,7)]

input_minus <- input_minus[, c(1,3,5,6,7)]
input_minus$Dist_start <- input_minus$End_CDS - input_minus$End_read 
input_minus$Dist_end <- input_minus$Start_CDS - input_minus$End_read 
input_minus <- input_minus[, c(1,5,6,7)]

input_merge <- rbind(input_minus, input_plus)

input_period <- input_merge
input_period <- input_period[, c(1,2,3)]
input_period$f0 <- input_period$Dist_start/3
input_period$f1 <- (input_period$Dist_start-1)/3
input_period$f2 <- (input_period$Dist_start-2)/3

is.wholenumber <- function(x, tol = .Machine$double.eps^0.5)  abs(x - round(x)) < tol

input_period$frame <- ifelse(is.wholenumber(input_period$f0) == TRUE, 0, ifelse(is.wholenumber(input_period$f1) == TRUE, 1, ifelse(is.wholenumber(input_period$f2) == TRUE, 2, NA)))
input_period_summ <- input_period %>%
  group_by(frame) %>%
  summarise(count = n()) %>%
  ungroup()

start_50 <- subset(input_merge, Dist_start > -51 & Dist_start < 51)
end_50 <- subset(input_merge, Dist_end > -51 & Dist_end < 51)

start_50 <- start_50[, c(1,2,3)]
end_50 <- end_50[, c(1,2,4)]

start_summ <- start_50 %>%
  group_by(Dist_start) %>%
  summarise(count=n()) %>%
  ungroup()

end_summ <- end_50 %>%
  group_by(Dist_end) %>%
  summarise(count=n()) %>%
  ungroup()
  
write.table(input_period_summ,paste0(outFolder, "/",Sample, '_peridocity_summ.txt'),sep='\t',row.names=F,quote=F)
write.table(start_summ,paste0(outFolder, "/",Sample, '_start_summ.txt'),sep='\t',row.names=F,quote=F)
write.table(end_summ,paste0(outFolder, "/",Sample, '_end_summ.txt'),sep='\t',row.names=F,quote=F)
