#!/bin/bash
set -x
#Input values
CRAMSLIST=$1
FAMID=$2
ENC_SSC_ACCESS_KEY=$3
ENC_SSC_SECRET_ACCESS_KEY=$4
STARTCHR=${5:-1}
SSC_PARAMS=${6}
echo "[run_advntr.sh]: ${FAMID}: ${CRAMSLIST}"

die()
{
    BASE=$(basename "$0")
    echo "$BASE error: $1" >&2
    exit 1
}

# #############
DATADIR=/scratch # This is where we have all the EBS storage space mounted

# Set up
mkdir -p ${DATADIR}/${FAMID}/datafiles
mkdir -p ${DATADIR}/${FAMID}/results
mkdir -p ${DATADIR}/${FAMID}/tmp/
rm ${DATADIR}/${FAMID}/results/*
rm ${DATADIR}/${FAMID}/datafiles/*
rm ${DATADIR}/${FAMID}/tmp/*

aws s3 cp s3://ssc-denovos/scripts/${SSC_PARAMS} ${DATADIR}/${FAMID}/${SSC_PARAMS} || die "Error copying ${SSC_PARAMS}"
source ${DATADIR}/${FAMID}/${SSC_PARAMS}
aws s3 cp s3://ssc-denovos/scripts/decrypt.py ${DATADIR}/${FAMID}/  || die "Error copying decrypt.py"
aws s3 cp s3://ssc-denovos/scripts/encrypt_code.txt ${DATADIR}/${FAMID}/  || die "Error copying encrypt_code.txt"


# Get encrypted SSC credentials
MESSAGE=$(cat ${DATADIR}/${FAMID}/encrypt_code.txt)
SSC_ACCESS_KEY=$(python3 ${DATADIR}/${FAMID}/decrypt.py ${MESSAGE} ${ENC_SSC_ACCESS_KEY})
SSC_SECRET_ACCESS_KEY=$(python3 ${DATADIR}/${FAMID}/decrypt.py ${MESSAGE} ${ENC_SSC_SECRET_ACCESS_KEY})

# Set up SSC profile
aws configure --profile ssc2 set aws_access_key_id $SSC_ACCESS_KEY
aws configure --profile ssc2 set aws_secret_access_key $SSC_SECRET_ACCESS_KEY
aws configure --profile ssc2 set region us-east-1

## First, download data files needed for GangSTR
# Ref genome from SSC
echo "[run_advntr.sh]: Downloading ref genome"
aws s3 --profile ssc2 cp ${REFFASTA} ${DATADIR}/${FAMID}/datafiles/ref.fa || die "Error copying GangSTR ref FASTA: ${REFFASTA}"
samtools faidx ${DATADIR}/${FAMID}/datafiles/ref.fa || die "Could not index ref fasta"

# GangSTR reference regions
echo "[run_advntr.sh]: Downloading adVNTR regions"
aws s3 cp GRCh38_VNTRs_chr${chrom}.db ${DATADIR}/${FAMID}/datafiles/GRCh38_VNTRs_chr${chrom}.db || die "Error copying adVNTR ref BED: ${chrom}"

# BAM files from SSC
echo "[run_gangstr.sh]: Downloading CRAMs"
for CRAM in $(echo ${CRAMSLIST} | sed "s/(//g" | sed "s/)//g" | sed "s/;/ /g")
do
  aws s3 --profile ssc2 cp ${CRAM} ${DATADIR}/${FAMID}/datafiles/ || die "Could not copy ${CRAM}"
  aws s3 --profile ssc2 cp ${CRAM}.crai ${DATADIR}/${FAMID}/datafiles/ || die "Could not copy ${CRAM}.crai"
done

CRAMSINPUT=$(ls ${DATADIR}/${FAMID}/datafiles/*.cram | tr '\n' ',' | sed 's/,$//') # Get comma sep list of crams
echo "CRAM files list" ${CRAMSINPUT}

if [ ${STARTCHR} == "X" ]; then
  ARRAY=(X Y)
elif [ ${STARTCHR} == "Y" ]; then
  ARRAY=(Y)
else
  #ARRAY=($(seq ${STARTCHR} 22) X Y)
  ARRAY=($(seq ${STARTCHR} 22))
fi

for chrom in "${ARRAY[@]}"
do
    cmd="echo [run_advntr.sh]: Running advntr chr${chrom}"

    ### Second, run GangSTR
    cmd="advntr \
    genotype
	--alignment_file ${CRAMSINPUT} \
	--models ${DATADIR}/${FAMID}/datafiles/GRCh38_VNTRs_chr${chrom}.db \
	-r ${DATADIR}/${FAMID}/datafiles/ref.fa \
    --working_directory ${DATADIR}/${FAMID}/tmp/\
    --outfmt bed \
	--out ${DATADIR}/${FAMID}/results/${FAMID}_${chrom}.bed"

    ### Third, upload results to S3
    cmd="${cmd} && aws s3 cp ${DATADIR}/${FAMID}/results/${FAMID}_${chrom}.sorted.vcf.gz ${GANGSTRDIR}/"
    echo $cmd
done | xargs sh -c "%"

### Cleanup before moving on to next job
rm ${DATADIR}/${FAMID}/results/*
rm ${DATADIR}/${FAMID}/datafiles/*
rm ${DATADIR}/${FAMID}/tmp/*
exit 0
