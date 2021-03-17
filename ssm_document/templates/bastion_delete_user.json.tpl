{
  "schemaVersion": "2.2",
  "description": "Document to delete the bastion database user when the bastion is terminated",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "deleteuser",
      "inputs": {
        "runCommand": [
          "echo 'REVOKE rds_iam FROM bastion_user; REVOKE USAGE ON SCHEMA public FROM bastion_user; REVOKE CONNECT ON DATABASE consignmentapi FROM bastion_user; REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM bastion_user; DROP USER bastion_user;' | PGPASSWORD=${db_password} psql -h ${db_host} -U ${db_username} -d consignmentapi"
        ]
      }
    }
  ]
}
