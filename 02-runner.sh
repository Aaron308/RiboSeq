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
02-runner.sh <number of threads> <min length> <error rate>"

######### Setup ################
threads=$1
min=$2 #discard any reads that drop below this value
#trim_length=$3 #Prior to adapter removal, hard trim all reads back to this length 
error_rate=$3 #Permitted error rate between sequence and adapter. If error rate is 0.1, then the maximum error allowed is 0.1 x the overlap (e.g. 1bp if overlap of 10bp), rounded down. 
if [ "$#" -lt "4" ]
then
echo $usage
exit -1
else
echo "initiating $1 parallel cutadapt adapter removal jobs, min length after filtering $min, sequences trimmed to $trim_length, error rate $error_rate"
fi
########## Run #################


#user defined variables that could be changed:
workingdir=./
script=$scriptdir/03-cutadapt.sh
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

findSamples | parallel -j $threads bash $script {} $min $error_rate \>logs/${outdir}.${timestamp}/{}.log 2\>\&1

#To run, got to directory containing reads directory and call:
#bash ~/path_to/02-runner.sh
