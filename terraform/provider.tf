terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    snowflake = {
      source = "snowflakedb/snowflake"
    }

  }
}

provider "aws" {
  region = var.default_region
}

provider "snowflake" {
  organization_name        = var.snowflake_organization_name
  account_name             = var.snowflake_account_name
  user                     = "TERRAFORM_SVC"
  role                     = "SYSADMIN"
  authenticator            = "SNOWFLAKE_JWT"
  private_key              = file(var.snowflake_private_key_path)
  preview_features_enabled = ["snowflake_stage_resource", "snowflake_file_format_resource"]
}