[
  {
    "name": "${project}-grafana",
    "image": "${app_image}",
    "cpu": 0,
    "secrets": [
      {
        "valueFrom": "${admin_user}",
        "name": "GF_SECURITY_ADMIN_USER"
      },
      {
        "valueFrom": "${admin_user_password}",
        "name": "GF_SECURITY_ADMIN_PASSWORD"
      },
      {
        "valueFrom": "${database_host_path}",
        "name": "GF_DATABASE_HOST"
      },
      {
        "valueFrom": "${database_user_path}",
        "name": "GF_DATABASE_USER"
      },
      {
        "valueFrom": "${database_password_path}",
        "name": "GF_DATABASE_PASSWORD"
      }
    ],
    "environment": [
      {
        "name": "GF_INSTALL_PLUGINS",
        "value": "https://github.com/mtanda/grafana-aws-cloudwatch-logs-datasource/releases/download/1.0.6/grafana-aws-cloudwatch-logs-datasource-1.0.6.zip;grafana-aws-cloudwatch-logs-datasource"
      },
      {
        "name": "GF_DATABASE_LOG_QUERIES",
        "value": "true"
      },
      {
        "name": "GF_DATABASE_MAX_IDLE_CONN",
        "value": "0"
      },
      {
        "name": "GF_DATABASE_TYPE",
        "value": "${database_type}"
      }
    ],
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ]
  }
]
