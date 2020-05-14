{
  "Version": "2012-10-17",
  "Id": "default_policy",
  "Statement": [
    {
      "Sid": "default_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SQS:GetQueueAttributes",
        "SQS:GetQueueUrl",
        "SQS:ListDeadLetterSourceQueues",
        "SQS:ReceiveMessage",
        "SQS:SendMessage"
      ],
      "Resource": "arn:aws:sqs:${region}:${account_id}:${sqs_name}"
    }
  ]
}
