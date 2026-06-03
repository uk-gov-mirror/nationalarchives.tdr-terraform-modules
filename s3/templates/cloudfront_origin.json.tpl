{
  "Version": "2012-10-17",
  "Id": "CloudfrontUploadBucketPolicy",
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
      "Sid": "AllowConditionalPut",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "cloudfront.amazonaws.com"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ],
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": ${cloudfront_distribution_arns}
        },
        "Null": {
          "s3:if-none-match": "false"
        }
      }
    },
    {
      "Sid": "AllowConditionalPutWithMPUs",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "cloudfront.amazonaws.com"
        ]
      },
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ],
      "Condition": {
        "Bool": {
          "s3:ObjectCreationOperation": "false"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "cloudfront.amazonaws.com"
        ]
      },
      "Action": "s3:PutObjectTagging",
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ],
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": ${cloudfront_distribution_arns}
        }
      }
    },
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
    }
  ]
}
