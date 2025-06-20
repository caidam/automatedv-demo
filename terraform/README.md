# Terraforming Snowflake

[source](https://quickstarts.snowflake.com/guide/terraforming_snowflake/index.html#2)

### Create a Service User for Terraform
We will now create a service user separate from your own user. A service-type user authenticate with Snowflake without a login and password but only with a key-pair approach. No need for password or MFA. This is also how most CI/CD pipelines run Terraform.

- Create an RSA key for Authentication
This creates the private and public keys we use to authenticate the service account we will use for Terraform.

```bash
    cd ~/.ssh
    openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out snowflake_tf_snow_key.p8 -nocrypt
    openssl rsa -in snowflake_tf_snow_key.p8 -pubout -out snowflake_tf_snow_key.pub
```

- Create the User in Snowflake
Log in to the Snowflake console and create the service user by running the following command as the ACCOUNTADMIN role.

But first:

Copy the text contents of the ~/.ssh/snowflake_tf_snow_key.pub file, including the PUBLIC KEY header and the PUBLIC KEY footer.
Paste all the content of your public key over the label (shown below).
Execute the following SQL statements to create the service user (SVC) and grant it access to the SYSADMIN and SECURITYADMIN roles needed for account management.

```sql
    USE ROLE ACCOUNTADMIN;

    CREATE USER TERRAFORM_SVC
        TYPE = SERVICE
        COMMENT = "Service user for Terraforming Snowflake"
        RSA_PUBLIC_KEY = "<RSA_PUBLIC_KEY_HERE>";

    GRANT ROLE SYSADMIN TO USER TERRAFORM_SVC;
    GRANT ROLE SECURITYADMIN TO USER TERRAFORM_SVC;
```

> We grant the user `SYSADMIN` and `SECURITYADMIN` privileges to keep the lab simple. An important security best practice, however, is to limit all user accounts to least-privilege access. In a production environment, the public key should also be secured with a secrets management solution like HashiCorp Vault, Azure Key Vault, AWS Secrets Manager, etc.

### Setup Terraform Authentication
We need to pass provider information to Terraform so it can authenticate as the user on our Snowflake account.

But first, run the following to find `YOUR_SNOWFLAKE_ACCOUNT`. Refer to the account identifiers documentation for more information.

```sql
SELECT LOWER(current_organization_name()) as your_org_name, LOWER(current_account_name()) as your_account_name;
```

With this information, copy the content of the following block to a new file we'll call main.tf.

Replace the your_org_name and your_account_name with your own
Update the private_key file path if you've created it somewhere else

The Snowflake Provider will use the information we provided to securely authenticate with your Snowflake account as the service user.

```h
terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
}

locals {
  organization_name = "your_org_name"
  account_name      = "your_account_name"
  private_key_path  = "~/.ssh/snowflake_tf_snow_key.p8"
}

provider "snowflake" {
    organization_name = local.organization_name
    account_name      = local.account_name
    user              = "TERRAFORM_SVC"
    role              = "SYSADMIN"
    authenticator     = "SNOWFLAKE_JWT"
    private_key       = file(local.private_key_path)
}
```

### Declaring Resources
In the the same main.tf file, let's add two configurations for the database and the warehouse that we want Terraform to create.

Copy the contents of the following block at the end of your main.tf file, following the provider information:

```h
resource "snowflake_database" "tf_db" {
  name         = "TF_DEMO_DB"
  is_transient = false
}

resource "snowflake_warehouse" "tf_warehouse" {
  name                      = "TF_DEMO_WH"
  warehouse_type            = "STANDARD"
  warehouse_size            = "XSMALL"
  max_cluster_count         = 1
  min_cluster_count         = 1
  auto_suspend              = 60
  auto_resume               = true
  enable_query_acceleration = false
  initially_suspended       = true
}
```

This is all the code needed to create these resources: a database and a XS virtual warehouse.

> Tip – You can split objects creation in as many .tf files as necessary, no need to keep everything in main.tf. Split them in a way that makes logical sense for your own use.

Snowflake objects creation, or resources in Terraform terms, all follow the same pattern. In the case of the database we just defined:

- `snowflake_database` is the type of the resource. In this case, a Snowflake database.
- `tf_db` is the resource name. You can name your resource whatever you want but we suggest to make it descriptive and unique. It will be used by Terraform to identify the resource when referencing it.
- `TF_DEMO_DB` is the name you want to give to your Snowflake object, how it will appear in Snowflake.
- `is_transient` is a parameter specific to this resource.

### Snowflake Stage Resource

[source](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/stage)

```h
resource "snowflake_stage" "example_stage" {
  name        = "EXAMPLE_STAGE"
  url         = "s3://com.example.bucket/prefix"
  database    = "EXAMPLE_DB"
  schema      = "EXAMPLE_SCHEMA"
  credentials = "AWS_KEY_ID='${var.example_aws_key_id}' AWS_SECRET_KEY='${var.example_aws_secret_key}'"
}

# with an existing hardcoded file format
# please see other examples in the snowflake_file_format resource documentation
resource "snowflake_stage" "example_stage_with_file_format" {
  name        = "EXAMPLE_STAGE"
  url         = "s3://com.example.bucket/prefix"
  database    = "EXAMPLE_DB"
  schema      = "EXAMPLE_SCHEMA"
  credentials = "AWS_KEY_ID='${var.example_aws_key_id}' AWS_SECRET_KEY='${var.example_aws_secret_key}'"
  file_format = "FORMAT_NAME = DB.SCHEMA.FORMATNAME"
}

variable "example_aws_key_id" {
  type      = string
  sensitive = true
}

variable "example_aws_secret_key" {
  type      = string
  sensitive = true
}
```


---

dbt external table : [source](https://hub.getdbt.com/dbt-labs/dbt_external_tables/latest/)