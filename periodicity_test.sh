#!/bin/bash
# bamtobed
#Takes bam file as input and outputs bed file

#Set -e as an option, it tells the command line to exit the script immediately if it registers an error.
set -e

alignFolder=$1
reference=$2

#Make list of samples name
cd $alignFolder
ls > ../samples_all.txt
cd ..

mkdir periodicity

#For each sample, make a bed file from the BAM file and put it in the output folder
while read i;
do
echo $alignFolder/$i/${i}.bam
mkdir periodicity/$i
intersectBed -bed -wo -S -abam $alignFolder/$i/${i}.bam -b $reference > periodicity/$i/${i}_intersect.temp.bed
cut -f 1-3,6,14-16,19 periodicity/$i/${i}_intersect.temp.bed > periodicity/$i/${i}_intersect.bed
rm -rv periodicity/$i/${i}_intersect.temp.bed
done <samples_all.txt

rm -rv samples_all.txt
