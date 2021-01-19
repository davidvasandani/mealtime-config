module "bucket_access_deny_user" {
  source    = "cloudposse/iam-system-user/aws"
  version   = "0.18.0"
  namespace = "mealtime"
  stage     = terraform.workspace
  name      = "deny_bucket_user"

  inline_policies_map = {
    s3 = data.aws_iam_policy_document.s3_policy.json
  }
}

# unless a user is explicty granted access to the images bucket
# they will be denied. The IAM policy here is superfluous
# and for demonstration purposes
data "aws_iam_policy_document" "s3_policy" {
  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

data "template_file" "bucket_access_deny_user" {
  template = <<JSON
#!/bin/bash

export AWS_ACCESS_KEY_ID=$${access_key_id}
export AWS_SECRET_ACCESS_KEY=$${secret_access_key}
JSON
  vars = {
    access_key_id     = module.bucket_access_deny_user.access_key_id
    secret_access_key = module.bucket_access_deny_user.secret_access_key
  }
}

resource "local_file" "bucket_access_deny_user" {
  content  = data.template_file.bucket_access_deny_user.rendered
  filename = "${path.module}/../../../test/.envrc_deny_user"
}
