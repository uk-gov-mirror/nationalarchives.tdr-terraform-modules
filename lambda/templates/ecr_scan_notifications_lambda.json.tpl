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
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-ecr-scan-notifications-mgmt",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-ecr-scan-notifications-mgmt:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ses:SendEmail",
      "Resource": [
        "arn:aws:ses:eu-west-2:${account_id}:identity/aws_tdr_management@nationalarchives.gov.uk",
        "arn:aws:ses:eu-west-2:${account_id}:identity/tdr-management.nationalarchives.gov.uk"
      ]
    }
  ]
}
