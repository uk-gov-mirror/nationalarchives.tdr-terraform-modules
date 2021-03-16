#!/bin/bash
mkdir -p /home/ssm-user
yum install -y postgresql jq
cat > /home/ssm-user/create-user <<- EOM
CREATE USER bastion_user;
GRANT CONNECT ON DATABASE consignmentapi TO bastion_user;
GRANT USAGE ON SCHEMA public TO bastion_user;
GRANT rds_iam TO bastion_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO bastion_user;
EOM
cat /home/ssm-user/create-user | PGPASSWORD=${db_password} psql -h ${db_host} -U ${db_username} -d consignmentapi | true
cat <<\EOF >> /home/ssm-user/connect.sh
FILE=/home/ssm-user/rds-combined-ca-bundle.pem
if [ ! -f "$FILE" ]; then
wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
fi
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
aws sts assume-role --role-arn arn:aws:iam::${account_number}:role/TDRBastionAccessDbRole${environment} --role-session-name bastionrolesession > creds
export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' creds)
export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' creds)
export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' creds)
export RDSHOST="${db_host}"
export PGPASSWORD="$(aws rds generate-db-auth-token --hostname $RDSHOST --port 5432 --region eu-west-2 --username bastion_user )"
psql "host=$RDSHOST port=5432 sslmode=verify-full sslrootcert=rds-combined-ca-bundle.pem dbname=consignmentapi user=bastion_user password=$PGPASSWORD"
EOF
chmod +x /home/ssm-user/connect.sh
chown -R 1001:1001 /home/ssm-user
history -c