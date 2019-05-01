FROM ubuntu:19.04
MAINTAINER James Turk <jpturk@princeton.edu>

RUN apt-get update && apt-get install -y \
        postgresql-client \
        jq \
        awscli
WORKDIR /scripts/
ADD . .
