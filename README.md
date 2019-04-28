# Prowler Batch

Prowler Batch is an AWS account security scanner specialist based on [Prowler script](https://github.com/toniblyx/prowler) and embedded into AWS Batch jobs.

## Description

People need to audit their account to seek security issues or validate compliance. Prowler Batch is here to do the job for you at a defined frequency.
It ensures cost containment and security hardening.
Reports are stored into an S3 Bucket.

## Technicals details

Prowler batch simply runs [Prowler script](https://github.com/toniblyx/prowler) into AWS Batch jobs.
It simply industrializes the deletion process thanks to the following AWS resources :
- CloudWatch Rule to trigger the deletion execution
- Batch to ensure a pay per use strategy
- ECR to host the Docker image that embeds Prowler
- Lambda to gather the accounts to perform and submit the jobs
- S3 to store generated reports
- Cloudwatch Logs to log the global activity

![Prowler Batch Diagram](images/prowlerbatch-diagram.png)

## Prerequisites

Prowler needs :
- a VPC
- a private subnet with Internet connection (through a NAT Gateway)

## Installation

1. deploy the cf-prowler-common.yml CloudFormation stack in the central account
2. Git clone prowler scans into this directory and build, tag and push the Docker image. Follow the information provided in the ECR repository page.
3. deploy the cf-prowler-org-account.yaml in the account using AWS Organizations
4. deploy the cf-prowler-spoke-account.yaml in all the accounts using to scan. To make it easy, use StackSets Stacks from the AWS Organizations level.
6. deploy the cf-prowler-batch.yml CloudFormation stack in the central account

Do not forget a strong ExternalId like UUID.

## How to use it

When installed, no action is needed.

## Extension

It is possible to export Prowler's results into csv files and run Athena on into for large investigations.
