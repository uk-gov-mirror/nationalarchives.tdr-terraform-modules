{
  "Version": "2012-10-17",
  "Id": "key-lambda-policy",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow lambda to decrypt environment variables",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${account_id}"
        },
        "StringLike": {
          "kms:EncryptionContext:LambdaFunctionName": ["tdr-api-update-${environment}","tdr-checksum-${environment}", "tdr-create-db-users-${environment}", "tdr-download-files-${environment}", "tdr-export-api-authoriser-${environment}", "tdr-file-format-${environment}", "tdr-yara-av-${environment}"]
        }
      }
    }
  ]
}