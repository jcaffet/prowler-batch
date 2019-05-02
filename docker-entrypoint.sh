#!/bin/sh

TMP_ASSUME_ROLE_FILE=/tmp/assume-role.json

if [ -z "${REPORTING_BUCKET}" ]; then echo "REPORTING_BUCKET not set !"; exit 1; fi
if [ -z "${PROWLER_SCAN_ROLE}" ]; then echo "PROWLER_SCAN_ROLE not set !"; exit 1; fi
if [ -z "${PROWLER_ROLE_EXTERNALID}" ]; then echo "PROWLER_ROLE_EXTERNALID not set !"; exit 1; fi

echo "Collecting credentials for ${ACCOUNT} with role ${PROWLER_SCAN_ROLE}"
aws sts assume-role --role-arn arn:aws:iam::${ACCOUNT}:role/${PROWLER_SCAN_ROLE} \
										--external-id ${PROWLER_ROLE_EXTERNALID} \
	                  --role-session-name ${PROWLER_SCAN_ROLE} \
										>${TMP_ASSUME_ROLE_FILE}

export AWS_SECRET_ACCESS_KEY=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SecretAccessKey`
if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then echo "AWS_SECRET_ACCESS_KEY not set !"; exit 1; fi

export AWS_ACCESS_KEY_ID=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.AccessKeyId`
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then echo "AWS_ACCESS_KEY_ID not set !"; exit 1; fi

export AWS_SESSION_TOKEN=`cat ${TMP_ASSUME_ROLE_FILE} | jq -r .Credentials.SessionToken`
if [ -z "${AWS_SESSION_TOKEN}" ]; then echo "AWS_SESSION_TOKEN not set !"; exit 1; fi

today=`date +'%Y-%m-%d'`
report_file_prefix=${ACCOUNT}-${today}-prowler

echo "Generating Prowler CIS checks report in ${report_file_prefix}-cis.txt ..."
./prowler -g cislevel2 -M mono >${report_file_prefix}-cis.txt

echo "Generating Prowler Extras checks report in ${report_file_prefix}-extras.txt ..."
./prowler -g extras -M mono >${report_file_prefix}-extras.txt

echo "Saving the report files in s3://${REPORTING_BUCKET}/${ACCOUNT}"
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
unset AWS_SESSION_TOKEN
aws s3 cp . s3://${REPORTING_BUCKET}/${ACCOUNT}/ \
						--exclude="*" \
						--include="${report_file_prefix}-*" \
						--recursive
