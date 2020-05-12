{
  "Version":"2012-10-17",
  "Statement":[
    {
      "sid": "s3-upload-publish",
      "Effect": "Allow",
      "Principal": {"AWS":"*"},
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:${region}:${account_id}:${sns_topic_name}",
      "Condition":{
        "ArnLike":{"aws:SourceArn":"arn:aws:s3:::tdr-*"}
      }
    },
    {
      "Sid": "sqs_subscribe",
      "Effect": "Allow",
      "Principal": {
        "AWS":"*"
      },
      "Action": "SNS:Subscribe",
      "Resource": "arn:aws:sns:${region}:${account_id}:${sns_topic_name}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn":"arn:aws:sqs:${region}:${account_id}:*"
        }
      }
    }
  ]
}