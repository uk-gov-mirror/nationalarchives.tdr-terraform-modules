{
  "Version": "2012-10-17",
  "Id": "efs-statement-export",
  "Statement": [
    {
      "Sid": "efs-statement-export",
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
