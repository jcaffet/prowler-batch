# Prowler Batch

Prowler Batch is an AWS account security scanner specialist based on [Prowler script](https://github.com/toniblyx/prowler) and embedded into AWS Batch jobs.

## Description

People need to audit their account to seek security issues or validate compliance. Prowler Batch is here to do the job for you at a defined frequency.
It ensures cost containment and security hardening.

## Design

### Diagram

![Prowler Batch Diagram](images/prowlerbatch-diagram.png)

## Content

Prowler batch simply runs [Prowler script](https://github.com/toniblyx/prowler) into AWS Batch jobs.
It industrializes the scan process thanks to the following AWS resources :
- CloudWatch Rule to trigger the deletion execution
- Batch to ensure a pay per use strategy
- ECR to host the Docker image that embeds Prowler
- Lambda to gather the accounts to perform and submit the jobs
- S3 to store generated reports
- CloudWatch Logs to log the global activity

### Explanation

The system works around two independent Lambdas :
- cloudsploit-job-launcher : retrieves all the accounts from AWS Organizations and submit as many AWS Batch jobs as there are accounts.  This Lambda is invoked by a CloudWatch rule but could be invoked manually.
- cloudsploit-account-harverster : it is in charge of updating the StackSet that spread on all accounts the role used by Batch jobs to scan the accounts. This Lambda is invoked by a CloudWatch rule but could be invoked manually.

## Installation

### Prerequisites

Prowler needs :
- a VPC
- a private subnet with Internet connection (through a NAT Gateway)

### Steps

1. deploy the [cf-prowler-common.yml](cf-prowler-common.yml) CloudFormation stack in the central account
2. Git clone prowler scans into this directory and build, tag and push the Docker image. Follow the information provided in the ECR repository page.
3. deploy the [cf-prowler-org-account.yml](cf-prowler-org-account.yml) in the account using AWS Organizations
4. deploy the [cf-prowler-spoke-account.yml](cf-prowler-spoke-account.yml) in all the accounts using to scan. To make it easy, use StackSets Stacks from the AWS Organizations level.
6. deploy the [cf-prowler-batch.yml](cf-prowler-batch.yml) CloudFormation stack in the central account

Do not forget a strong ExternalId like UUID.

## How to use it

When installed, no action is needed. New accounts are involved and you just have to enjoy looking the results in the S3 bucket.

## Extension

It is possible to export Prowler's results into csv files and run Athena on results for large investigations or compliance reports.
