{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPullConsignmentAPI",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${intg_account}:role/keycloak_ecs_execution_role_intg",
          "arn:aws:iam::${staging_account}:role/keycloak_ecs_execution_role_staging",
          "arn:aws:iam::${prod_account}:role/keycloak_ecs_execution_role_prod"
        ]
      },
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
