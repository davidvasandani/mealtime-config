variable "run_type" {
  type = string
}

# usually we would use terraform locals but because local_file.content already
# include the yaml kv here it isn't compatible
# 
# locals {
#   ansible_variables = {
#     bucket_name       = module.image_bucket.bucket_id
#     access_key_id     = data.local_file.access_key_id.content
#     secret_access_key = data.local_file.secret_access_key.content
#   }
# }
#
# resource "local_file" "ansible_variables" {
#   content  = yamlencode(local.ansible_variables)
#   filename = "../../ansible/vars.yml"
# }
#

module "ansible_vault_access_key_id" {
  source  = "matti/resource/shell"
  depends = [module.image_bucket.access_key_id]
  command = join(" ", [
    "ansible-vault", "encrypt_string",
    "--vault-id ${terraform.workspace}@${path.module}/../../../ansible/.vault_pass_${var.run_type}",
    "'${module.image_bucket.access_key_id}'",
    "--name 'access_key_id'"
  ])
}

module "ansible_vault_secret_access_key" {
  source  = "matti/resource/shell"
  depends = [module.image_bucket.secret_access_key]
  command = join(" ", [
    "ansible-vault", "encrypt_string",
    "--vault-id ${terraform.workspace}@${path.module}/../../../ansible/.vault_pass_${var.run_type}",
    "'${module.image_bucket.secret_access_key}'",
    "--name 'secret_access_key'"
  ])
}

output "shell_stderr" {
  value = map(
    "key_stderr", module.ansible_vault_access_key_id.stderr,
    "secret_stderr", module.ansible_vault_secret_access_key.stderr
  )
}

data "template_file" "ansible_variables" {
  template = <<JSON
---
bucket_name: $${bucket_id}
$${access_key_id}
$${secret_access_key}
...
JSON
  vars = {
    bucket_id         = module.image_bucket.bucket_id
    access_key_id     = module.ansible_vault_access_key_id.stdout
    secret_access_key = module.ansible_vault_secret_access_key.stdout
  }
}

resource "local_file" "ansible_variables" {
  content  = data.template_file.ansible_variables.rendered
  filename = "${path.module}/../../../ansible/vars.yml"
}

# optionally format yaml output
# resource "null_resource" "image_bucket_name" {
#   depends_on = [local_file.ansible_variables]
#   triggers   = { ansible_variables = local_file.ansible_variables.content }
#   provisioner "local-exec" {
#     command = join(" ", [
#       "yq", "eval", "../../ansible/vars.yml", ">", "../../ansible/vars_updated.yml"
#     ])
#   }
# }
