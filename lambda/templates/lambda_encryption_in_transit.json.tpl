{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "kms:Decrypt",
    "Resource": "${kms_key_id}",
    "Condition": {
      "StringEquals": {
        "kms:EncryptionContext:LambdaFunctionName": "${function_name}"
      }
    }
  }
}
