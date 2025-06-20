# s3 bucket
resource "aws_s3_bucket" "snowflake-bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "snowflake-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.snowflake-bucket.id

  policy = <<-POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": "${aws_iam_user.s3_user.arn}"},
      "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
  ]
}
POLICY
}

# s3 policy
# "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"],
# "Action": ["s3:*"],
resource "aws_iam_policy" "s3_policy" {
  # name        = "MyS3Policy"
  # description = "My test S3 policy"
  name        = "snowflake-ots-s3-policy"
  description = "S3 policy for snowflake project"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.bucket_name}/*"]
    }
  ]
}
EOF
}

# dedicated iam user
resource "aws_iam_user" "s3_user" {
  name = var.user_name
  path = "/system/"
}

resource "aws_iam_access_key" "s3_user_keys" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy_attachment" "s3_user_policy_attachment" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# save credentials
# resource "null_resource" "credentials_file" {
#   provisioner "local-exec" {
#     command = <<-EOF
#       echo AWS_ACCESS_KEY=${aws_iam_access_key.s3_user_keys.id} > ../.env &&
#       echo AWS_SECRET_KEY=${aws_iam_access_key.s3_user_keys.secret} >> ../.env &&
#       echo S3_BUCKET_NAME=${var.bucket_name} >> ../.env &&
#       echo AWS_DEFAUL_REGION=${var.default_region} >> ../.env &&

#     EOF
#   }
#   depends_on = [aws_iam_access_key.s3_user_keys]
# }

# upload files

resource "aws_s3_object" "region_file" {
  bucket = aws_s3_bucket.snowflake-bucket.id
  key    = "/tpch_sf10_region.csv"
  source = "${path.module}/tpch_sf10_region.csv"
  etag   = filemd5("${path.module}/tpch_sf10_region.csv")
}

resource "aws_s3_object" "nation_file" {
  bucket = aws_s3_bucket.snowflake-bucket.id
  key    = "/tpch_sf10_nation.csv"
  source = "${path.module}/tpch_sf10_nation.csv"
  etag   = filemd5("${path.module}/tpch_sf10_region.csv")
}


# snowflake

# db and warehouse creation
resource "snowflake_database" "tf_db" {
  name         = "DV_PROTOTYPE_DB2"
  is_transient = false
}

resource "snowflake_warehouse" "tf_warehouse" {
  name                      = "DV_PROTOTYPE_WH2"
  warehouse_type            = "STANDARD"
  warehouse_size            = "XSMALL"
  max_cluster_count         = 1
  min_cluster_count         = 1
  auto_suspend              = 60
  auto_resume               = true
  enable_query_acceleration = false
  initially_suspended       = true
}

# s3 stage creation
resource "snowflake_file_format" "tpch_ff" {
  name        = "TPCH_CSV_FMT"
  database    = snowflake_database.tf_db.name
  schema      = "PUBLIC"
  format_type = "CSV"
  skip_header = 1
}

resource "snowflake_stage" "s3_stage" {
  name        = "S3_DV_STAGE"
  url         = "s3://${var.bucket_name}/" #"s3://com.example.bucket/prefix"
  database    = snowflake_database.tf_db.name
  schema      = "PUBLIC"
  credentials = "AWS_KEY_ID='${aws_iam_access_key.s3_user_keys.id}' AWS_SECRET_KEY='${aws_iam_access_key.s3_user_keys.secret}'"
  #   directory_enabled = true
  #   directory = true
  file_format = "FORMAT_NAME = ${snowflake_file_format.tpch_ff.database}.${snowflake_file_format.tpch_ff.schema}.${snowflake_file_format.tpch_ff.name}"
  #   copy_options = 
  #   depends_on = [aws_iam_access_key.s3_user_keys, aws_s3_bucket.snowflake-bucket]
}

# https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/stage

#   credentials = "AWS_KEY_ID='${var.example_aws_key_id}' AWS_SECRET_KEY='${var.example_aws_secret_key}'"

# variable "example_aws_key_id" {
#   type      = string
#   sensitive = true
# }

# variable "example_aws_secret_key" {
#   type      = string
#   sensitive = true
# }