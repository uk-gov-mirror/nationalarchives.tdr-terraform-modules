{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "states:SendTaskSuccess",
        "states:SendTaskFailure"
      ],
      "Resource": [
        "arn:aws:states:${aws_region}:{account}:stateMachine:TDRConsignmentExport${titleEnvironment}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:ClientWrite"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::tdr-upload-files-${environment}/*",
        "arn:aws:s3:::tdr-upload-files-${environment}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::tdr-consignment-export-${environment}/*",
        "arn:aws:s3:::tdr-consignment-export-${environment}"
      ]
    }
  ]
}

