# Prowler Batch

Prowler Batch is an AWS account security scanner specialist based on [Prowler scanner engine](https://github.com/toniblyx/prowler) and embeded into AWS Batch jobs.

## Description

People need to audit their account to seek security issues or validate compliance. Prowler Batch is here to do the job for you at a defined frenquency.
It ensures cost containment and security hardening.

## Technicals details

Prowler batch simply runs [Prowler scanner engines](https://github.com/toniblyx/prowler) into AWS Batch jobs.
It simply industrializes the deletion process thanks to the following AWS ressources :
- CloudWatch Rule to trigger the deletion execution
- Batch to ensure a pay per use strategy
- ECR to host the Docker image that embeds aw-nuke
- Lambda to gather the accounts to perform and submit the jobs
- S3 to store generated reports
- Cloudwatch Logs to log the global acitivity

![Prowler Batch Diagram](images/prowlerbatch-diagram.png)

## Prerequisites

Prowler needs :
- a VPC
- a private subnet with Internet connection (through a NAT Gateway)

## Installation

1. deploy the cf-prowler-common.yml Cloudformation stack in the central account
2. Git clone prowler scans into this directory and build, tag and push the Docker image. Follow the information provided in the ECR repository page.
3. deploy the cf-prowler-org-account.yaml in the account using AWS Organizations
4. deploy the cf-prowler-spoke-account.yaml in all the accounts using to scan. To make it easy, use StackSets Stacks from tha Organzations level.
6. deploy the cf-prowler-batch.yml Cloudformation stack in the central account

## How to use it
Scans are perform on a conigured daily basis and reports are stored in the S3 bucket.

