provider "aws" {
  region                      = "us-west-1"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    es             = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    route53        = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

# in production these modules would source repo under semver

module "image_bucket" {
  depends_on = [module.ansible_vault]
  source     = "../modules/image-bucket"
  run_type   = "localstack"
}

module "ansible_vault" {
  source   = "../modules/ansible-vault"
  run_type = "localstack"
}

output "image_bucket_stderr" {
  value = module.image_bucket.shell_stderr
}

output "ansible_vault_stderr" {
  value = module.ansible_vault.shell_stderr
}

