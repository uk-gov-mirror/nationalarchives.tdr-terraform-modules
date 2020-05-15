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
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-api-update-antivirus-${environment}",
        "arn:aws:logs:eu-west-2:${account_id}:log-group:/aws/lambda/tdr-api-update-antivirus-intg:log-stream:*"
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
        "${input_sqs_arn}",
        "${sqs_arn}"

      ]
    }
  ]
}