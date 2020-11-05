{
  "Comment": "A state machine to run the Fargate task to export the consginment",
  "StartAt": "Run ECS task",
  "States": {
    "Run ECS task": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${cluster_arn}",
        "TaskDefinition": "${task_arn}",
        "PlatformVersion": "1.4.0",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "AssignPublicIp": "ENABLED",
            "SecurityGroups": ${security_groups},
            "Subnets": ${subnet_ids}
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "${task_name}",
              "Environment": [
                {
                  "Name": "CONSIGNMENT_ID",
                  "Value.$": "$.consignmentId"
                }
              ]
            }
          ]
        }
      },
      "End": true
    }
  }
}