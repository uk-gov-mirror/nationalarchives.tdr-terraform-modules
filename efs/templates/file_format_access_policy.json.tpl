{
  "Version": "2012-10-17",
  "Id": "efs-policy-file-format",
  "Statement": [
    {
      "Sid": "efs-statement-file-format",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ]
    }
  ]
}