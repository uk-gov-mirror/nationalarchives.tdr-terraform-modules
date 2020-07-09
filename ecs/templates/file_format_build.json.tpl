[
  {
    "name": "fileformatbuild",
    "image": "nationalarchives/file-format-build:${app_environment}",
    "networkMode": "awsvpc",
    "mountPoints": [
      {
        "containerPath": "/tmp/fileformatbuild",
        "sourceVolume": "fileformatbuild"
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
