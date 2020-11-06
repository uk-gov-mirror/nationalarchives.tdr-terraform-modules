{
  "Id": "alb-logging-${bucket_name}",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${tna_account}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${bucket_name}/*"
    }
  ]
}
