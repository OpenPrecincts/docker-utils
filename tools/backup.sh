#!/bin/sh
set -e

export PGPASSWORD=$(aws ssm get-parameter --name /op/production/DB_PASSWORD --with-dec | jq -r .Parameter.Value)
export PGHOST=$(aws ssm get-parameter --name /op/production/DB_HOST --with-dec | jq -r .Parameter.Value)
export S3_BUCKET=openprecincts-internal
export PGUSER=openprecincts_production

pg_dump -Fc openprecincts_production > backup.pgdump
aws s3 cp backup.pgdump s3://${S3_BUCKET}/production-backups/`date +%Y/%m/%Y%m%d`-openprecincts_production.pgdump
rm backup.pgdump
