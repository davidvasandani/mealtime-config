output "image_bucket_stderr" {
  value = module.image_bucket.shell_stderr
}

output "ansible_vault_stderr" {
  value = module.ansible_vault.shell_stderr
}
