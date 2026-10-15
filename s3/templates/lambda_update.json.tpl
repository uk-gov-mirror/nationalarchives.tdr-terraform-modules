{
  "Version": "2012-10-17",
  "Id": "secure-transport-tdr-backend-code-mgmt",
  "Statement": [
  %{ if aws_backup_local_role != "" }
    {
      "Sid": "AllowSourceAWSBackupRoleAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_backup_local_role}"
      },
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:ListBucketVersions"
      ],
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ]
    },
  %{ endif }
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${external_account_1}:role/TDRGithubActionsDeployLambdaIntg",
          "arn:aws:iam::${external_account_2}:role/TDRGithubActionsDeployLambdaStaging",
          "arn:aws:iam::${external_account_3}:role/TDRGithubActionsDeployLambdaProd",
          "arn:aws:iam::${external_account_4}:role/TDRGithubActionsDeployLambdaDev"
        ]
      },
      "Action": ["s3:GetObject"],
      "Resource": [
        "arn:aws:s3:::${bucket_name}/*"
      ]
    }
  ]
}
