locals {
  namespace = "mealtime"
  name      = "images"
}

module "image_bucket" {
  source                 = "cloudposse/s3-bucket/aws"
  version                = "0.28.0"
  acl                    = "private" # conflicts with grants.
  versioning_enabled     = false
  user_enabled           = true # create user with allowed_bucket_actions
  allowed_bucket_actions = ["s3:*Object", "s3:ListBucket"]
  name                   = local.name
  stage                  = terraform.workspace
  namespace              = local.namespace
  force_destroy          = true
  policy                 = <<POLICY
{
  "Id": "ImageBucketPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ImageBucketPolicy",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.namespace}-${terraform.workspace}-${local.name}",
      "Principal": {
        "AWS": [
          "arn:aws:iam:::user/${local.namespace}-${terraform.workspace}-${local.name}"
        ]
      }
    }
  ]
}
POLICY
}
