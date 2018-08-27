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

usage="USAGE:
02-runner.sh <number of threads> <min length> <trim length>"

######### Setup ################
threads=$1
min_length=$2
trim_length=$3
if [ "$#" -lt "2" ]
then
echo $usage
exit -1
else
echo "initiating $1 parallel cutadapt quality trim and adapter removal jobs, minimum length $2, trimmed length $3"
fi
########## Run #################

#user defined variables that could be changed:
workingdir=./
script=$scriptdir/02-cutadapt.sh
outdir=reads_noadapt
###

function findSamples () {
find reads/ -mindepth 1 -maxdepth 1 -type d  -exec basename {} \;| tr ' ' '\n'
}

mkdir $outdir
timestamp=$(date +%Y%m%d-%H%M%S)

logdir="./logs/${outdir}.${timestamp}"
mkdir $logdir

cat $script > "$logdir/script.log"
cat $0 > "$logdir/runner.log"
cat $script

findSamples | parallel -j $threads bash $script {} $min_length $trim_length \>logs/${outdir}.${timestamp}/{}.log 2\>\&1

#To run, got to directory containing reads directory and call:
#bash ~/path_to/02-runner.sh
