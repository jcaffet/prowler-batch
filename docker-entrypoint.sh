#!/bin/sh

TMP_ASSUME_ROLE_FILE=/tmp/assume-role.json

echo "Collecting credentials for ${ACCOUNT} for role ${PROWLER_ROLE_TO_ASSUME}"
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT}:role/${PROWLER_ROLE_TO_ASSUME} \
	            --role-session-name ${PROWLER_ROLE_TO_ASSUME} >${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`

now=`date +'%Y-%m-%d'`
report_file_prefix=${ACCOUNT}-${now}
echo "Generating CloudSploit CIS LEVEL1 report ..."
./prowler -g cislevel1 -M csv >${report_file_prefix}-cislevel1.csv
./prowler -g cislevel1 -M mono >${report_file_prefix}-cislevel1.txt

echo "Generating CloudSploit CIS LEVEL2 report ..."
./prowler -g cislevel2 -M csv >${report_file_prefix}-cislevel2.csv
./prowler -g cislevel2 -M mono >${report_file_prefix}-cislevel2.txt

echo "Saving the report files in s3://${PROWLER_BUCKET}/reports/${ACCOUNT}"
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
unset AWS_SESSION_TOKEN
aws s3 cp . s3://${PROWLER_BUCKET}/reports/${ACCOUNT}/ --exclude="*" --include="${report_file_prefix}-cislevel*" --recursive

