{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:StartImageScan",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:ListImages"
      ],
      "Resource": "arn:aws:ecr:eu-west-2:${account_id}:repository/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-ecr-scan-${environment}",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-ecr-scan-${environment}:log-stream:*"
      ]
    }
  ]
}