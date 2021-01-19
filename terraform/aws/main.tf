terraform {
  required_version = ">= 0.12.2"

  # Usually we'd manually setup the backend once for
  # for future use during local development or CI
  # backend "s3" {
  #   region         = "us-west-1"
  #   bucket         = "mealtime-shared-terraform-state"
  #   key            = "shared/terraform.tfstate"
  #   dynamodb_table = "mealtime-shared-terraform-state-lock"
  #   profile        = ""
  #   role_arn       = ""
  #   encrypt        = "true"
  # }
}

module "image_bucket" {
  depends_on = [module.ansible_vault]
  source     = "../modules/image-bucket"
  run_type   = "aws"
}

module "ansible_vault" {
  source   = "../modules/ansible-vault"
  run_type = "aws"
}
