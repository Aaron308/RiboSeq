#!/bin/bash
#Set -e as an option, it tells the command line to exit the script immediately if it registers an error.
set -e

#Set -x as an option, it tells the computer to echo back each step before it is completed and the output is produced. 
set -x

###
#code to make script work on both osx and linux. Essentially, it creates a file path to the script directory and saves this path as $0. In detail: 'if the operating system type is darwin (a mac), then use the greadlink function when the readlink function is called. Then use the greadlink function to find the script file named. In doing so, find the path of the script files directory and save as 'scriptdir'. This change is made for Macs because readlink doesn't run properly, but greadlink does. If the OS is not mac (eg. Linux), find the script file using the readlink function and save the path to the script file directory as 'scriptdir.' By using readlink to find where the scripts are, it means if this pipeline is copied onto another computer, the files can still be found.
if
[[ $OSTYPE == darwin* ]]
then
readlink=$(which greadlink)
scriptdir="$(dirname $($readlink -f $0))"
else
scriptdir="$(dirname $(readlink -f $0))"
fi
#


#Defines the sample that we are working with to the command line as the first token.
sample=$1
min=$2
error_rate=$3

#Specifies the directory that the sample will be opened from.
sample_dir=reads/$sample

#List all files ending with '.fastq.gz' that are located within the specified sample directory and save these as the variable 'fastqs.'
fastqs="$(ls $sample_dir/*q.gz)"

#Creates a new directory called 'reads_noadapt' and within this a folder for the sample. This creates the directory to put the output from into (next step).

outdir="reads_noadapt/$sample"
mkdir $outdir

outdir_discard="reads_noadapt/${sample}/discard"
mkdir $outdir_discard

#This command runs cutadapt. It says 'for the fastqs listed within the sample directory do the following:
#1) Keep the file names but remove the file extensions
#2) Store the output files in the specified sample folder within the reads_noadapt directory. Store the file name as 'samplename.noadapt.fq.gz' 
#3) Run the cutadapt function
#4) -a The adapter sequence to trim
#5) -e Error rate for overlap between sequence and adapter 
#6) -q Quality threshold for trimming
#7) -m Minimum read length: discard reads if trimmed to smaller than m
#8) -u Length to hard trim from 3' end prior to adapter trimming
# -o output file (reads_noadapt/given sample name)
# input file

for fq in $fastqs
do
fqname="$(basename $fq)"
outputFile="$outdir/${fqname%%.*}.noadapt.fq.gz"
outputFile2="$outdir/${fqname%%.*}.trimmed.fq.gz"
outputFile_untrimmed="$outdir_discard/${fqname%%.*}.no_adapt_found.fq.gz"

cutadapt \
-a "CTGTAGGCACCATCAAT" \
-e $error_rate \
-q 20 \
-m $min \
--untrimmed-output $outputFile_untrimmed \
-o $outputFile \
$fq

cutadapt \
-q 20 \
-m $min \
-o $outputFile2 \
$outputFile

rm -rv $outputFile
done
