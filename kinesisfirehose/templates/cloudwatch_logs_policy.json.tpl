{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "firehoselist",
      "Effect": "Allow",
      "Action": [
        "firehose:ListDeliveryStreams"
      ],
      "Resource": "*"
    },
    {
      "Sid": "firehose",
      "Effect": "Allow",
      "Action": [
        "firehose:DescribeDeliveryStream",
        "firehose:PutRecord",
        "firehose:PutRecordBatch"
      ],
      "Resource": "${kinesis_stream_arn}"
    },
    {
      "Sid": "PassRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
    "Resource": "${cloudwatch_logs_role_arn}"
    }
  ]
}
