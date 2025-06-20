[Looker Report](https://lookerstudio.google.com/s/vN_cQWPGOr0)

## Set up

### Clone this repo

### Set Up Terraform

Follow steps from [readme in terraform folder](/terraform/README.md)
generate ssh keys, create and configure service user in snowflake

create and populate `terraform.tfvars` file following `terraform.tfvars.template` structure

### Set Up dbt

- Create `profiles.yml` file following `profiles.yml.template` structure
- export `profiles.yml`

```bash
cd automate-dv-demo
export DBT_PROFILES_DIR=$(pwd)
```

> this is done for ease of use here but is not recommended in real world scenarios, avoid storing your credentials in the project folder and if so make sure the file is not tracked by git

- Sync uv and test

```bash
uv sync
uv run dbt debug
```

> uv

Init uv project inside existing folder with relevant python version
```bash
cd automate-dv-demo
uv init --python 3.9

```

Install dependencies
```bash
uv add dbt-core dbt-snowflake
uv sync
```

test dbt is working
```bash
uv run dbt --version
uv run dbt debug
uv run dbt deps
```