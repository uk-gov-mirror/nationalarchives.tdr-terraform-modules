# tdr-terraform-modules
* Terraform modules for use by other TDR repositories

## usage
* clone into the root directory of the repository using the module
```
git clone git@github.com:nationalarchives/tdr-terraform-modules.git
```
* specify a branch or tag when cloning if needed
* example block of code to call a module:
```
module "guardduty-s3" {
  source      = "./tdr-terraform-modules/s3"
  project     = "tdr"
  function    = "guardduty"
  common_tags = local.common_tags
}
```

## modules
* Amazon Machine Image (AMI)
* Application Load Balancer (ALB)
* Athena
* Certificate Manager
* CloudTrail
* Config
* GuardDuty
* Key Management Service (KMS)
* Kinesis Firehose
* Route 53
* Security Hub
* Simple Email Service (SES)
* Simple Notification Service (SNS)
* Simple Storage Service (S3)
* Web Application Firewall (WAF) - should be upgraded to WAFv2 when supported by Terraform
