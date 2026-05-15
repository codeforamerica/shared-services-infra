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

resource "aws_iam_role" "rewrite_function" {
  name               = "${local.prefix}-rewrite-function"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_policy" "rewrite_function" {
  name        = "${local.prefix}-rewrite-function"
  path        = "/"
  description = "Permissions for the URI rewrite Lambda function."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.identity.account_id}:log-group:/aws/lambda/${local.prefix}-rewrite",
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.identity.account_id}:log-group:/aws/lambda/${local.prefix}-rewrite:*",
          "arn:${data.aws_partition.current.partition}:logs:*:${data.aws_caller_identity.identity.account_id}:log-group:/aws/lambda/*.${local.prefix}-rewrite",
          "arn:${data.aws_partition.current.partition}:logs:*:${data.aws_caller_identity.identity.account_id}:log-group:/aws/lambda/*.${local.prefix}-rewrite:*",
        ]
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "rewrite_function" {
  role       = aws_iam_role.rewrite_function.name
  policy_arn = aws_iam_policy.rewrite_function.arn
}
