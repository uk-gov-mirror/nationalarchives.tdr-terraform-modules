{
  "Version": "2012-10-17",
  "Id": "Key policy created by Terraform",
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
      "Sid": "Allow CloudTrail to encrypt logs",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "kms:GenerateDataKey*",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${account_id}:trail/*"
        }
      }
    },
    {
      "Sid": "Allow CloudTrail to describe key",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "kms:DescribeKey",
      "Resource": "*"
    },
    {
      "Sid": "Allow principals in the account to decrypt log files",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${account_id}"
        },
        "StringLike": {
          "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${account_id}:trail/*",
          "kms:EncryptionContext:LambdaFunctionName": ["tdr-log-data-intg", "tdr-log-data-staging", "tdr-log-data-prod", "tdr-log-data-mgmt", "tdr-notifications-mgmt"]
        }
      }
    },
    {
      "Sid": "Allow alias creation during setup",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "kms:CreateAlias",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "ec2.eu-west-2.amazonaws.com",
          "kms:CallerAccount": "${account_id}"
        }
      }
    },
    {
      "Sid": "Enable cross account log decryption",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      "Resource": "*",
        "Condition": {
        "StringEquals": {
          "kms:CallerAccount": "${account_id}"
        },
        "StringLike": {
          "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${account_id}:trail/*"
        }
      }
    }
  ]
}