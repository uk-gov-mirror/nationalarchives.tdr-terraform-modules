{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${intg_account}:role/TDRFileFormatECSExecutionRoleIntg",
          "arn:aws:iam::${staging_account}:role/TDRFileFormatECSExecutionRoleStaging"
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