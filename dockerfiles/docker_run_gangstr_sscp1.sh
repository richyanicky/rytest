
#!/bin/bash

# Run this script on snorlax inside script dir
BAMSLIST='(s3://pg-bam/SRR4435250.bam;s3://pg-bam/SRR4435251.bam;s3://pg-bam/SRR4435252.bam)'
FAMID='TEST'

AWS_ACCESS_KEY_ID=$(cat ~/.aws/credentials  | grep id | cut -f 2 -d '=' | head -n 1 | cut -f 2 -d' ')
AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials  | grep secret | cut -f 2 -d '=' | head -n 1 | cut -f 2 -d' ')
aws s3 cp sscp1_params.sh s3://ssc-gangstr/scripts/sscp1_params.sh || echo "sscp1_params.sh upload to s3 failed"
aws s3 cp run_gangstr_sscp1.sh s3://ssc-gangstr/scripts/run_gangstr_sscp1.sh || echo "run_gangstr_sscp1.sh upload to s3 failed"
docker run \
       -v /storage/ileena/scratch:/scratch \
       --env BATCH_FILE_TYPE="script" \
       --env BATCH_FILE_S3_URL="s3://ssc-gangstr/scripts/run_gangstr_sscp1.sh" \
       --env AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
       --env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
       -it gymreklab/str-toolkit-run gangstr_pg_test.sh ${BAMSLIST} ${FAMID}
