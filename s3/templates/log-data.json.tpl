{
  "Id": "secure-logging-${bucket_name}",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    },
    {
      "Sid": "AllowOtherAccounts",
      "Action": "s3:*",
      "Effect": "Allow",
      "Principal": {
          "AWS": [
            "arn:aws:iam::${external_account_1}:role/TDRLogDataAssumeRoleIntg"
        ]
      },
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ]
    }
  ]
}
