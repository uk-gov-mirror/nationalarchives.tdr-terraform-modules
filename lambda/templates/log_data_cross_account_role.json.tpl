{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${account_id}:root",
          "arn:aws:iam::${external_account_1}:root",
          "arn:aws:iam::${external_account_2}:root",
          "arn:aws:iam::${external_account_3}:root"
        ],
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}