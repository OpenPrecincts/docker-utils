#!/bin/sh
set -e

cd $1
docker build . -t $1

REPO="$(aws ecr describe-repositories --repository-names $1 | jq -r .repositories[0].repositoryUri)"

eval "$(aws ecr get-login --no-include-email)"
docker tag $1:latest $REPO
docker push $REPO
