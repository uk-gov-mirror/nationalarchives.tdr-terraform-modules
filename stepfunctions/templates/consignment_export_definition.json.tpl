{
  "Comment": "A state machine to run the Fargate task to export the consginment",
  "StartAt": "Run ECS task",
  "States": {
    "Run ECS task": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.waitForTaskToken",
      "Catch": [
        {
          "ErrorEquals": [
            "States.TaskFailed"
          ],
          "Next": "Handle escaped JSON from error cause"
        }
      ],
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
              "Name": "consignmentexport",
              "Environment": [
                {
                  "Name": "CONSIGNMENT_ID",
                  "Value.$": "$.consignmentId"
                },
                {
                  "Name":"TASK_TOKEN_ENV_VARIABLE",
                  "Value.$":"$$.Task.Token"
                }
              ]
            }
          ]
        }
      },
      "Next": "Task complete notification"
    },
    "Task complete notification": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": {
          "consignmentId.$": "$.Overrides.ContainerOverrides[0].Environment[0].Value",
          "success": true,
          "environment": "${environment}"
        },
        "TopicArn": "${sns_topic}"
      },
      "End": true
    },
    "Handle escaped JSON from error cause": {
      "Type": "Pass",
      "Parameters": {
        "Cause.$": "States.StringToJson($.Cause)"
      },
      "Next": "Task failed notification"
    },
    "Task failed notification": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": {
          "consignmentId.$": "$.Cause.Overrides.ContainerOverrides[0].Environment[0].Value",
          "success": false,
          "environment": "${environment}"
        },
        "TopicArn": "${sns_topic}"
      },
      "End": true
    }
  }
}