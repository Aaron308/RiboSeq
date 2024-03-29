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
reads=$2
b_threads=$3
refdir=$4

#Specifies the directory that the sample will be opened from. In this case, it is opening a sample folder located in the 'reads_noadapt_trimmed' folder.
sample_dir="$reads/$sample"

#Defines the output directory to be a folder with the sample name located within the 'align' directory. This will be used in the next step to create an output directory. 
outdir="align_bowtie2/${sample}"

#Creates an output directory to put the returned files to go into once subread has been run on the sample. In this case, the output from subread for the sample should go into a folder containing the sample's name, located within the 'align' directory.
mkdir ${outdir}

#List all files ending with 'trimmed.fq' that are located within the specified sample directory and save these as the variable 'fastqs.'
fastqs="$(ls $sample_dir/*.fq*)"


numFqFiles=$(echo $fastqs | wc -w)

#Specifies that the sam output file will be placed in the output directory, and have the file name 'sample.sam'
outsam="${outdir}/${sample}.sam"

#Specifies that the bam output file will be stored in the output directory, with the file name 'sample.''.bam' has not been added as samtools sort -f currently (29/4/14) has a bug. 
outbam="${outdir}/${sample}" # no .bam, as samtools sort -f has a bug.

#Specifies that the temporary bam output file will be stored in the output directory with the file name 'random.bam.' A temporary bam file has been created due to samtools having a bug with the bam files (Kevins hackery).
tmpbam="${outdir}/${RANDOM}.bam"


bowtie2 \
-x ${refdir}/TAIR10/bowtie2_refdir/TAIR10 \
--phred33 \
--end-to-end \
--mm \
-D 20 \
-R 3 \
-N 1 \
-L 5 \
-i S,1,0.50 \
-p $b_threads \
-U $fastqs \
-S "$outsam"

#-x bowtie index
#--phred33
#--end-to-end dont trim reads to enable alignment
#--mm memory-mapped I/O to load index allow multiple processes to use index
#-p number of threds to use
#-U fastq file path, and specifies reads are not paired
#-S file to write SAM alignemnts too (although default is stdout anyhow)
#-D and -R tell bowtie to try a little harder than normal to find alignments
#-L reduce substring length to 10 (default 22) as these are short reads
#-i reduce substring interval? more sensitive?
# --score-min C,0,0 would tell bowtie2 to report only exact matches in --end-to-end mode (alignment score of 0 required which is max possible in end mode)
#-N max # mismatches in seed alignment; can be 0 or 1 (0)
#-D give up extending after <int> failed extends in a row

echo "samtools view -S -u $outsam > ${tmpbam}
samtools sort -m 2G ${tmpbam} $outbam
samtools index ${outbam}.bam
rm -v ${outsam} ${tmpbam}"

#Using samtools view to convert the sam file to bam file.
samtools view -q 10 -S -u $outsam > ${tmpbam}

#Sort the temporary bam file by chromosomal position, and save the sorted file.
samtools sort -m 2G ${tmpbam} -o $outbam.bam

#Make an index of the sorted bam file
samtools index ${outbam}.bam

#Delete the temporary bam.
rm -v ${outsam} ${tmpbam}
