#!/bin/sh
set -e 

export PGPASSWORD=$(aws ssm get-parameter --name /op/staging/DB_PASSWORD --with-dec | jq -r .Parameter.Value)
export PGHOST=$(aws ssm get-parameter --name /op/production/DB_HOST --with-dec | jq -r .Parameter.Value)
export S3_BUCKET=openprecincts-internal
export PGUSER=openprecincts_staging

echo "running make-staging-db.5"

psql -c "DROP DATABASE IF EXISTS tmpdb;"
createdb tmpdb;
aws s3 cp s3://${S3_BUCKET}/backups/latest/openprecincts_production.pgdump backup.pgdump 
pg_restore backup.pgdump -d tmpdb;

psql tmpdb -c "UPDATE auth_user set first_name='', last_name='', password='!', email='', last_login=null,  username=md5(username);"
psql tmpdb -c "UPDATE files_file set s3_path=concat('test/', s3_path);"
psql tmpdb -c "TRUNCATE silk_profile, silk_request, silk_response, silk_sqlquery, django_admin_log, django_session cascade;"
# maybe clean up userprofiles and email messages as those become relevant

pg_dump -Fc tmpdb > backup.pgdump
aws s3 cp backup.pgdump s3://${S3_BUCKET}/backups/openprecincts_testdb.pgdump
rm backup.pgdump
