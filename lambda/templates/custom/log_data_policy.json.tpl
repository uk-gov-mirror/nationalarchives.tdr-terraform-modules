{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GetLogs",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PutLogs",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::tdr-log-data-mgmt"
    }
  ]
}
