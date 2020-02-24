# tdr-terraform-modules

* Terraform modules for use by other TDR repositories

## usage
* clone into the root directory of the repository using the module
```
git clone https://github.com/nationalarchives/tdr-terraform-modules
```
* specify a branch or tag when cloning if needed
* example block of code to call a module:
```
module "guardduty-s3" {
  source      = "tdr-terraform-modules/s3"
  project     = "tdr"
  function    = "guardduty"
  common_tags = local.common_tags
}
```