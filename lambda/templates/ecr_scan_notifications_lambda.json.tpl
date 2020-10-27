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
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-ecr-scan-notifications-${environment}",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-ecr-scan-notifications-${environment}:log-stream:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ses:SendEmail",
      "Resource": [
        "arn:aws:ses:eu-west-2:${account_id}:identity/tdr-secops@nationalarchives.gov.uk",
        "arn:aws:ses:eu-west-2:${account_id}:identity/tdr-management.nationalarchives.gov.uk"
      ]
    }
  ]
}
