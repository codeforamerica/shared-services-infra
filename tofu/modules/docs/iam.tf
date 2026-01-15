resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  tags = local.tags
}

resource "aws_iam_policy" "prefix" {
  for_each = local.apps

  name        = "${local.prefix}-deploy-${each.key}"
  path        = "/"
  description = "Allow deploy access to ${each.key} in the documentation bucket"

  policy = jsonencode(yamldecode(templatefile("${local.template_dir}/prefix-policy.yaml.tftpl", {
    bucket_arn : module.bucket.arn,
    prefix : each.key
  })))

  tags = local.tags
}

resource "aws_iam_role" "deploy" {
  for_each = local.apps

  name = "${local.prefix}-${each.key}-deploy"

  assume_role_policy = jsonencode(yamldecode(templatefile("${local.template_dir}/deploy-assume-policy.yaml.tftpl", {
    oidc_arn : aws_iam_openid_connect_provider.github.arn,
    repository : each.value.repo
  })))

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "deploy" {
  for_each = local.apps

  role       = aws_iam_role.deploy[each.key].name
  policy_arn = aws_iam_policy.prefix[each.key].arn
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "oidc_function" {
  name               = "${local.prefix}-oidc-function"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_policy" "oidc_function" {
  name        = "${local.prefix}-oidc-function"
  path        = "/"
  description = "Permissions for the OIDC authentication Lambda function."

  policy = jsonencode(yamldecode(templatefile("${local.template_dir}/oidc-function-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id,
    partition : data.aws_partition.current.partition,
    region : data.aws_region.current.name,
    function_name : "${local.prefix}-oidc",
    secret_arn : module.secrets.secrets["OIDC_SETTINGS"].secret_arn,
  })))

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "oidc_function" {
  role       = aws_iam_role.oidc_function.name
  policy_arn = aws_iam_policy.oidc_function.arn
}
