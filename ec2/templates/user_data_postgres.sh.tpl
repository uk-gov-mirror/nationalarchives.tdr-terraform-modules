sudo yum update -y && sudo yum install -y postgresql && \
  echo "${db_host}:5432:consignmentapi:${db_username}:${db_password}" > /home/ssm-user/.pgpass && \
  chown ssm-user:ssm-user /home/ssm-user/.pgpass