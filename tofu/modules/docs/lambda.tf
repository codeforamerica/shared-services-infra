# Build the package.json file for the OIDC Lambda function.
resource "local_file" "pkg_json" {
  content = templatefile("${local.lambda_dir}/oidc/package.json.tftpl", {
    lambda_name = "${local.prefix}-oidc",
  })
  filename = "${local.build_dir}/oidc/package.json"
}

# Build the Lambda function code.
resource "local_file" "lambda_js" {
  content = templatefile("${local.lambda_dir}/oidc/index.js.tftpl", {
    protected_prefixes = local.protected_prefixes,
    secret_arn         = module.secrets.secrets["oidc"].secret_arn
  })
  filename = "${local.build_dir}/oidc/index.js"
}

# Install dependencies using npm when package.json changes.
resource "null_resource" "npm_install" {
  depends_on = [local_file.pkg_json, local_file.lambda_js]

  triggers = {
    package_json_hash = sha256(local_file.pkg_json.content)
    modules_exist = fileexists("${local.build_dir}/oidc/node_modules/.package-lock.json")
  }

  provisioner "local-exec" {
    command = "npm install --prefix ${local.build_dir}/oidc"
  }
}

data "archive_file" "oidc" {
  depends_on = [local_file.pkg_json, local_file.lambda_js, null_resource.npm_install]

  type        = "zip"
  source_dir  = "${local.build_dir}/oidc"
  output_path = "${local.build_dir}/oidc-function.zip"
}

#trivy:ignore:AVD-AWS-0066
resource "aws_lambda_function" "oidc" {
  filename         = data.archive_file.oidc.output_path
  function_name    = "${local.prefix}-oidc"
  role             = aws_iam_role.oidc_function.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.oidc.output_base64sha256
  publish          = true

  runtime = "nodejs22.x"

  tags = merge(local.tags, { use = "edge-function" })
}
