variable "run_type" {
  type = string
}

resource "aws_secretsmanager_secret" "ansible_vault" {
  name                    = "ansible-vault"
  recovery_window_in_days = 0
}

resource "random_string" "ansible_vault_password" {
  length  = 36
  special = true
  number  = true
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret_version" "ansible_vault" {
  secret_id = aws_secretsmanager_secret.ansible_vault.id
  secret_string = jsonencode({
    default = {
      password = random_string.ansible_vault_password.result
    }
  })
}

# store vault pass in secrets manager
# when running ansible vault call .vault_pass
# which queries secrets manager for the password

module "vault_pass" {
  source  = "matti/resource/shell"
  depends = [aws_secretsmanager_secret_version.ansible_vault.version_id]
  command = join(" ", [
    "rm", "-f", "${path.module}/../../../ansible/secrets.yml",
    "&&",
    "ansible-vault", "create",
    "--vault-id", "${terraform.workspace}@${path.module}/../../../ansible/.vault_pass_${var.run_type}",
    "${path.module}/../../../ansible/secrets.yml"
  ])
}

output "shell_stderr" {
  value = map(
    "vault_pass_stderr", module.vault_pass.stderr,
  )
}
