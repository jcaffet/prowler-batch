FROM amazonlinux:latest
RUN yum -y install which unzip aws-cli jq tar gzip

ADD ./prowler /prowler
ADD docker-entrypoint.sh /prowler/docker-entrypoint.sh
RUN chmod 744 /prowler/docker-entrypoint.sh

WORKDIR /prowler
ENTRYPOINT ["/prowler/docker-entrypoint.sh"]

