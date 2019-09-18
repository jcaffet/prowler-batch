FROM amazonlinux:latest

RUN yum -y update \
 && yum -y install aws-cli which unzip jq tar gzip python3-pip \
 && yum clean all

RUN pip3 install ansi2html detect-secrets

WORKDIR /prowler

ADD ./prowler /prowler
ADD docker-entrypoint.sh /prowler/docker-entrypoint.sh
RUN chmod 744 /prowler/docker-entrypoint.sh
ENTRYPOINT ["/prowler/docker-entrypoint.sh"]
