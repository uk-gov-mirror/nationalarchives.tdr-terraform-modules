{
  "Comment": "A state machine to run the Fargate task to export the consignment",
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
          "Next": "Task failed notification"
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
          "consignmentId.$": "$$.Execution.Input.consignmentId",
          "success": true,
          "environment": "${environment}",
          "successDetails.$": "$"
        },
        "TopicArn": "${sns_topic}"
      },
      "End": true
    },
    "Task failed notification": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": {
          "consignmentId.$": "$$.Execution.Input.consignmentId",
          "success": false,
          "environment": "${environment}",
          "failureCause.$": "$.Cause"
        },
        "TopicArn": "${sns_topic}"
      },
      "Next": "Fail State"
    },
    "Fail State": {
       "Type": "Fail"
    }
  }
}
