#!/bin/bash

usage(){
    echo "Usage: $0 <profile>" 
    echo "profile : aws profile to use for deployment" 
}

if [ $# -eq 1 ]; then
   profile=$1
else
   usage;
   exit 1;
fi

echo "Creating stack"
APP=prowler
aws --profile=${profile} cloudformation create-stack \
    --stack-name ${APP}-common \
    --capabilities CAPABILITY_NAMED_IAM \
    --template-body file://cf-${APP}-common.yml \
    --parameters ParameterKey=TagBlock,ParameterValue=security \
                 ParameterKey=TagApp,ParameterValue=${APP} \
                 ParameterKey=TagOrg,ParameterValue=cloudaccelerationteam \
                 ParameterKey=ProwlerEcrRepoName,ParameterValue=cloudaccelerationteam/${APP}

