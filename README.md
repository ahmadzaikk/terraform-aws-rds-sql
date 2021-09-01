# terraform-aws-rds-sql
Terraform module which creates RDS SQL server resources on AWS



-->

Terraform module to provision AWS [`RDS SQL server`]



## Introduction

The module will create:

* RDS SQL server 



## Usage
1. Create terragrunt.hcl config file and past the following configuration.
2. Create your policies and save it under the same directory that your HCL file is located.

```hcl

#
# Include all settings from root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


dependency "sg" {
  config_path = "../sg-test"
}

inputs = {
  enabled                 = true
  subnet_ids              = ["subnet-xxxxxxxxx", "subnet-xxxxxxx"]
  allocated_storage       = "30"
  max_allocated_storage   = "50"
  engine                  = "sqlserver-se" # change to sqlserver-ee to install enterprise version
  identifier              = "rds-test-dlp"
  engine_version          = "15.00.4073.23.v1"
  instance_class          = "db.m5.2xlarge"
  secret_manager_name     = "secret-manager-rds-test-kk-dlpk"
  publicly_accessible     = true
  deletion_protection     = false
  apply_immediately       = true
  backup_retention_period = "14"
  vpc_security_group_ids  = [dependency.sg.outputs.id]
  license_model = "license-included"
  tags = {
    "ucop:application" = "DLP"
    "ucop:createdBy"   = "Terraform"
    "ucop:enviroment"  = "Prod"
    "ucop:group"       = "CHS"
    "ucop:source"      = join("/", ["https://github.com/ucopacme/ucop-terraform-config/tree/master/terraform/its-chs-dev/us-west-2", path_relative_to_include()])
  }

}

terraform {
     source = "git::https://git@github.com/ucopacme/terraform-aws-rds-sql.git?ref=v0.0.1"


}
