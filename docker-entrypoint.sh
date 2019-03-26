#!/bin/sh

TMP_ASSUME_ROLE_FILE=/tmp/assume-role.json

echo "Collecting credentials for ${ACCOUNT} for role ${PROWLER_ROLE_TO_ASSUME}"
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT}:role/${PROWLER_ROLE_TO_ASSUME} \
	            --role-session-name ${PROWLER_ROLE_TO_ASSUME} >${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then echo "AWS_SECRET_ACCESS_KEY not set !"; exit 1; fi
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then echo "AWS_ACCESS_KEY_ID not set !"; exit 1; fi
if [ -z "${AWS_SESSION_TOKEN}" ]; then echo "AWS_SESSION_TOKEN not set !"; exit 1; fi

now=`date +'%Y-%m-%d'`
report_file_prefix=${ACCOUNT}-${now}

echo "Generating CloudSploit CIS LEVEL1 report in ${report_file_prefix}-cislevel1.txt ..."
# possible export formats : mono, csv, json, html, ...
./prowler -g cislevel1 -M mono >${report_file_prefix}-cislevel1.txt

echo "Generating CloudSploit CIS LEVEL2 report in ${report_file_prefix}-cislevel2.txt ..."
# possible export formats : mono, csv, json, html, ...
./prowler -g cislevel2 -M mono >${report_file_prefix}-cislevel2.txt

echo "Saving the report files in s3://${PROWLER_BUCKET}/reports/${ACCOUNT}"
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
unset AWS_SESSION_TOKEN
aws s3 cp . s3://${PROWLER_BUCKET}/reports/${ACCOUNT}/ --exclude="*" --include="${report_file_prefix}-cislevel*" --recursive

