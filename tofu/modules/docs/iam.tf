resource "aws_iam_policy" "prefix" {
  for_each = var.prefixes

  name        = "${local.prefix}-deploy-${each.value}"
  path        = "/"
  description = "Allow deploy access to ${each.value} in the documentation bucket"

  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/prefix-policy.yaml.tftpl", {
    bucket_arn : module.bucket.arn,
    prefix : each.value
  })))
}
