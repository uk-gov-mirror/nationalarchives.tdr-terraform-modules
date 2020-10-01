{
  "Version": "2012-10-17",
  "Id": "efs-policy-backend-checks",
  "Statement": [
    {
      "Sid": "efs-statement-backend-checks",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ],
      "Resource": "${file_system_arn}"
    }
  ]
}
