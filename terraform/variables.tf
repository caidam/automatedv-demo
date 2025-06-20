# variables

# aws & s3
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "user_name" {
  description = "The name of the IAM user"
  type        = string
}

variable "default_region" {
  description = "The name of the IAM user default region"
  type        = string
}

# snowflake
variable "snowflake_organization_name" {
  description = "The name of the snowflake org"
  type        = string
}

variable "snowflake_account_name" {
  description = "The name of the snowflake account"
  type        = string
}

variable "snowflake_private_key_path" {
  description = "Path of the ssh private key for snowflake"
  type        = string
}

