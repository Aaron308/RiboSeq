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
periodicity_analysis.R <periodicity files> <threads>"

######### Setup ################
alignFolder=$1
threads=$2

if [ "$#" -lt "2" ]
then
echo $usage
exit -1
else
echo "making summaried periodicity files \n alignment folder = $1\n iniating $2 parallel jobs"
fi
########## Run #################


#user defined variables that could be changed:
workingdir=./
script=$scriptdir/periodicity_analysis.R
###

function findSamples () {
    find $alignFolder/ -mindepth 1 -maxdepth 1 -type d  -exec basename {} \;| tr ' ' '\n'
}

outdir=$alignFolder

logdir="${outdir}/.logs_${timestamp}"
mkdir $logdir

cat $script > "${logdir}/script.log"
cat $0 > "${logdir}/runner.log"
cat $script

findSamples | parallel -j $threads R -f $script --args {} $alignFolder $outdir \>${logdir}/{}.log 2\>\&1
