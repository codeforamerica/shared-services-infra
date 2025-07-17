resource "aws_iam_policy" "prefix" {
  for_each = local.apps

  name        = "${local.prefix}-deploy-${each.key}"
  path        = "/"
  description = "Allow deploy access to ${each.key} in the documentation bucket"

  policy = jsonencode(yamldecode(templatefile("${local.template_dir}/prefix-policy.yaml.tftpl", {
    bucket_arn : module.bucket.arn,
    prefix : each.key
  })))
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
    secret_arn : module.secrets.secrets["oidc"].secret_arn,
  })))
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.oidc_function.name
  policy_arn = aws_iam_policy.oidc_function.arn
}
