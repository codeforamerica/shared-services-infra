resource "aws_iam_policy" "deploy" {
  name        = "${local.prefix}-deploy"
  path        = "/"
  description = "Allow deploy access to the ${var.application_name} static app prefix."

  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/deploy-policy.yaml.tftpl", {
    application      = var.application_name,
    bucket_arn       = var.bucket_arn,
    distribution_arn = var.distribution_arn,
    kms_key_arn      = var.kms_key_arn,
  })))

  tags = var.tags
}

resource "aws_iam_role" "deploy" {
  name = "${local.prefix}-deploy"

  assume_role_policy = jsonencode(yamldecode(templatefile("${path.module}/templates/deploy-assume-policy.yaml.tftpl", {
    oidc_arn   = data.aws_iam_openid_connect_provider.github.arn,
    repository = var.repo,
  })))

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "deploy" {
  role       = aws_iam_role.deploy.name
  policy_arn = aws_iam_policy.deploy.arn
}
