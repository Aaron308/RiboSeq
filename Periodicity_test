#!/bin/bash
set -e
set -x

###
#code to make it work on osx and linux
if
[[ $OSTYPE == darwin* ]]
then
readlink=$(which greadlink)
scriptdir="$(dirname $($readlink -f $0))"
else
scriptdir="$(dirname $(readlink -f $0))"
fi
#

###
#agrs
sample=$1
alignFolder=$2
reference=$3
outdir=$4

sample_dir=$alignFolder/$sample
outFolder="${outdir}/${sample}"
mkdir ${outFolder}

bedtools intersect -abam $sample_dir/$sample.bam -b $reference -bed -wo -S > $outFolder/$sample_intersect.temp.bed

cut -f 1-3,6,14-16,19 $outFolder/$sample_intersect.temp.bed > $outFolder/$sample_intersect.bed

rm -rv $outFolder/$sample_intersect.temp.bed
