[
  {
    "name": "fileformatbuild",
    "image": "${management_account}.dkr.ecr.eu-west-2.amazonaws.com/consignment-export:${app_environment}",
    "networkMode": "awsvpc",
    "mountPoints": [
      {
        "containerPath": "/tmp/export",
        "sourceVolume": "consignmentexport"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "eu-west-2",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
