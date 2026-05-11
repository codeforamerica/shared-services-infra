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
    account       = data.aws_caller_identity.identity.account_id,
    partition     = data.aws_partition.current.partition,
    region        = data.aws_region.current.name,
    function_name = "${local.prefix}-oidc",
    secret_arn    = module.secrets.secrets["OIDC_SETTINGS"].secret_arn,
  })))

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "oidc_function" {
  role       = aws_iam_role.oidc_function.name
  policy_arn = aws_iam_policy.oidc_function.arn
}
