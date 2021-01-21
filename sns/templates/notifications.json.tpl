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
        "sns:GetTopicAttributes",
        "sns:SetTopicAttributes",
        "sns:AddPermission",
        "sns:RemovePermission",
        "sns:DeleteTopic",
        "sns:Subscribe",
        "sns:ListSubscriptionsByTopic",
        "sns:Publish",
        "sns:Receive"
      ],
      "Resource": "arn:aws:sns:${region}:${account_id}:${sns_topic_name}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${account_id}"
        }
      }
    },
    {
      "Sid": "lambda-access",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${management_account}:root"
      },
      "Action": [
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic"
      ],
      "Resource": "arn:aws:sns:${region}:${account_id}:${sns_topic_name}"
    }
  ]
}