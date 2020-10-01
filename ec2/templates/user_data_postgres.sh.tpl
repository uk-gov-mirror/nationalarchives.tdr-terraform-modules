#!/bin/bash
yum update -y
yum install -y postgresql
mkdir -p /home/ssm-user
echo "${db_host}:5432:consignmentapi:${db_username}:${db_password}" > /home/ssm-user/.pgpass
chmod 600 /home/ssm-user/.pgpass
chown -R 1001:1001 /home/ssm-user
