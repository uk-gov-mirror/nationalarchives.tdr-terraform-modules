{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GetLogs",
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PutLogs",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::tdr-log-data-mgmt/*"
    },
    {
      "Sid": "AssumeRole",
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${mgmt_account_id}:role/TDRLogDataCrossAccountRoleMgmt"
    }
  ]
}
