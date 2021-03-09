{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPullConsignmentAPI",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${intg_account}:role/TDRConsignmentExportECSExecutionRoleIntg",
          "arn:aws:iam::${staging_account}:role/TDRConsignmentExportECSExecutionRoleStaging",
          "arn:aws:iam::${prod_account}:role/TDRConsignmentExportECSExecutionRoleProd"
        ]
      },
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
