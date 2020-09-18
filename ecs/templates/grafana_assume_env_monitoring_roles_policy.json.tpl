{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::${intg_account_id}:role/${project_prefix}GrafanaMonitoringRoleIntg",
        "arn:aws:iam::${prod_account_id}:role/${project_prefix}GrafanaMonitoringRoleProd",
        "arn:aws:iam::${staging_account_id}:role/${project_prefix}GrafanaMonitoringRoleStaging"]
    }
  ]
}