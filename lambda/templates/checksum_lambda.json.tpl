{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-checksum-${environment}",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-checksum-${environment}:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": [
        "${update_queue}",
        "${input_sqs_queue}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "elasticfilesystem:ClientWrite"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:DescribeMountTargets"
      ],
      "Resource" : "arn:aws:elasticfilesystem:eu-west-2:${account_id}:file-system/${file_system_id}"
    },
    {
      "Sid": "DecryptEnvVar",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": "arn:aws:kms:eu-west-2:229554778675:key/b05401ed-cc76-46f6-bf2c-76cb0a859542"
    }
  ]
}
