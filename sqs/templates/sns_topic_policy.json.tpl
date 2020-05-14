{
  "Version": "2012-10-17",
  "Id": "sns_topic_policy",
  "Statement": [
    {
      "Sid": "sns_topic_statement",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "SQS:SendMessage",
      "Resource": "arn:aws:sqs:${region}:${account_id}:${sqs_name}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:sns:${region}:${account_id}:*"
        }
      }
    }
  ]
}