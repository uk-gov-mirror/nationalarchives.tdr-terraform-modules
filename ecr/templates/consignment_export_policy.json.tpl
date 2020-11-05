{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPullConsignmentAPI",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${intg_account}:role/TDRConsignmentExportECSExecutionRoleIntg"
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
