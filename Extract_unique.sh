#!/bin/bash
# bamtobed
#Takes bam file as input and outputs bed file

#Set -e as an option, it tells the command line to exit the script immediately if it registers an error.
set -e

alignFolder=$1

#Make list of samples name
cd $alignFolder
ls > ../samples_all.txt
cd ..

while read i;
do
echo $alignFolder/$i/${i}.bam
samtools view -H $alignFolder/$i/${i}.bam > $alignFolder/$i/${i}.header.sam
samtools view -F 4 $alignFolder/$i/${i}.bam | grep -v "XS:" | $alignFolder/$i/${i}.header.sam - | \
samtools view -b - > $alignFolder/$i/${i}.unique.bam
rm $alignFolder/$i/${i}.header.sam
done <samples_all.txt

rm -rv samples_all.txt
