#!/usr/bin/env sh
rm -r temp_logs
mkdir -p temp_logs
cd temp_logs
BUCKET=lb-access-logs-20221020065122754400000001
aws s3 cp s3://$BUCKET/ ./ --recursive
cp $(find . -path "*/logs/*" -name "*.gz") .
gunzip ./*.gz
cat ./*.log
cd ..