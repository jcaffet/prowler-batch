FROM amazonlinux:latest

RUN yum -y update \
 && yum -y install which unzip aws-cli jq tar gzip \
 && yum clean all

WORKDIR /prowler

ADD ./prowler /prowler
ADD docker-entrypoint.sh /prowler/docker-entrypoint.sh
RUN chmod 744 /prowler/docker-entrypoint.sh
ENTRYPOINT ["/prowler/docker-entrypoint.sh"]
