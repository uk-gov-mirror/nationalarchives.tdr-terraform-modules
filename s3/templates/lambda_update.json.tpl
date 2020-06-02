{
  "Version": "2012-10-17",
  "Id": "secure-transport-tdr-backend-code-mgmt",
  "Statement": [
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::tdr-backend-code-mgmt",
        "arn:aws:s3:::tdr-backend-code-mgmt/*"
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
          "arn:aws:iam::${external_account_1}:role/TDRJenkinsLambdaRoleIntg",
          "arn:aws:iam::${external_account_2}:role/TDRJenkinsLambdaRoleStaging",
          "arn:aws:iam::${external_account_3}:role/TDRJenkinsLambdaRoleProd"
        ]
      },
      "Action": ["s3:GetObject"],
      "Resource": [
        "arn:aws:s3:::tdr-backend-code-mgmt/*"
      ]
    }
  ]
}