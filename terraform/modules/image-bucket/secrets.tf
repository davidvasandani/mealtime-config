resource "aws_secretsmanager_secret" "this" {
  name                    = "mealtime-image-bucket-user"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    default = {
      aws_access_key = module.image_bucket.access_key_id
      aws_secret_key = module.image_bucket.secret_access_key
    }
  })
}
