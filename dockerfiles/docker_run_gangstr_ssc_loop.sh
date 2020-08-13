#!/bin/bash

# Run this script on snorlax inside script dir
# Run command ./aws_job_run_gangstr_ssc_loop.sh

SSC_FILE='../files/SSC_crams.test'

# Upload scripts
aws s3 cp ../sscp1_params.sh s3://ssc-gangstr/scripts/ || echo "sscp1_params.sh upload to s3 failed"
aws s3 cp ../pipeline/run_gangstr_sscp1.sh s3://ssc-gangstr/scripts/ || echo "run_gangstr_sscp1.sh upload to s3 failed"
aws s3 cp ../src/decrypt.py s3://ssc-gangstr/scripts/ || echo "decrypt.py upload to s3 failed"

SSC_ACCESS_KEY=$(cat ~/.aws/credentials | grep -A 2 ssc2 | grep id | cut -f 2 -d '=' | cut -f 2 -d' ' )
SSC_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials | grep -A 2 ssc2 | grep secret | cut -f 2 -d '=' | cut -f 2 -d' ' )
ENC_SSC_ACCESS_KEY=$(python3 ../src/encrypt.py "password" ${SSC_ACCESS_KEY})
ENC_SSC_SECRET_ACCESS_KEY=$(python3 ../src/encrypt.py "password" ${SSC_SECRET_ACCESS_KEY})

# Read SSC family list
while read -r FAMID CRAMSLIST; do
 # Check VCF files exsits - if missing, then run gangSTR
  STARTCHR=0
  for chrom in $(seq 1 22) X Y
  do
    VCF=vcf/${FAMID}_${chrom}.sorted.vcf.gz
    #if file does not exist, set start chrom number to chrom
    aws s3api head-object --bucket ssc-gangstr --key ${VCF} || STARTCHR=${chrom}
    if [ ${STARTCHR} -ne 0 ]; then
      break
    fi
  done

  # call submit job if any of the chroms were missing
   if [ ${STARTCHR} -ne 0 ]; then
   echo "Run GangSTR for ${FAMID} chr${STARTCHR}"
   docker run \
          -v /storage/ileena/scratch:/scratch \
          --env BATCH_FILE_TYPE="script" \
          --env BATCH_FILE_S3_URL="s3://ssc-gangstr/scripts/run_gangstr_sscp1.sh" \
          --env AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
          --env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
          -it ileena/cookiemonstr-run:v1 run_gangstr_sscp1.sh '"${CRAMSLIST}"','"${FAMID}"','"${ENC_SSC_ACCESS_KEY}"','"${ENC_SSC_SECRET_ACCESS_KEY}"','"${STARTCHR}"'
  fi
done <${SSC_FILE}
