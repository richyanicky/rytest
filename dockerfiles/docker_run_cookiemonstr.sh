#!/bin/bash

# SSC_FILE='../files/SSC_phase1_crams_125input.tab'
SSC_FILE='../files/SSC_crams.test'

aws s3 cp ../sscp1_params.sh s3://ssc-gangstr/scripts/ || echo "sscp1_params.sh upload to s3 failed"
aws s3 cp ../pipeline/run_cookiemonstr.sh s3://ssc-gangstr/scripts/run_cookiemonstr.sh || echo "run_cookiemonstr.sh upload to s3 failed"
AWS_ACCESS_KEY_ID=$(cat ~/.aws/credentials  | grep id | cut -f 2 -d '=' | head -n 1 | cut -f 2 -d' ')
AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials  | grep secret | cut -f 2 -d '=' | head -n 1 | cut -f 2 -d' ')

while read -r FAMID CRAMSLIST; do
   not_missing=true
   # Check .filtered.vcf.gz VCF files exsits - if missing, then do not run CookieMonSTR
   # for chrom in $(seq 1 22) X Y
   # do
   #   VCF=vcf/${FAMID}_${chrom}.sorted.vcf.gz
   #  aws s3api head-object --bucket ssc-gangstr --key ${VCF} || not_missing=false
   #  if (! ${not_missing}); then
   #    echo "File missing: s3://ssc-gangstr/${VCF}"
   #    break
   #  fi
   # done
   if (${not_missing}); then
     echo "Run cookiemonstr for ${FAMID}"
     docker run \
          -v /storage/ileena/scratch:/scratch \
          --env BATCH_FILE_TYPE="script" \
          --env BATCH_FILE_S3_URL="s3://ssc-gangstr/scripts/run_cookiemonstr.sh" \
          --env AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
          --env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
          ileena/cookiemonstr-run:v1 run_cookiemonstr.sh '"${FAMID}"'

   fi
done <${SSC_FILE}
