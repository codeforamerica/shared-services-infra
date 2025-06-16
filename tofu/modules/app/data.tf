data "aws_caller_identity" "identity" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_rds_engine_version" "this" {
  engine  = local.database_engine
  version = var.database_version
  latest  = true
}

# Find log groups that were created for the application so we can ingest their
# logs into Datadog.
data "aws_cloudwatch_log_groups" "ecs" {
  log_group_name_prefix = "/aws/ecs/${var.project}/${var.environment}/"
}

data "aws_cloudwatch_log_groups" "ecs_insights" {
  log_group_name_prefix = "/aws/ecs/containerinsights/${var.project}-${var.environment}"
}

data "aws_cloudwatch_log_groups" "rds" {
  log_group_name_prefix = "/aws/rds/instance/${var.project}-${var.environment}"
}

# Find the lambda function for the Datadog forwarder so that we can use it as a
# destination for CloudWatch log subscriptions.
data "aws_lambda_functions" "all" {}

data "aws_lambda_function" "datadog" {
  for_each = length(local.datadog_lambda) > 0 ? toset(["this"]) : toset([])

  function_name = local.datadog_lambda[0]
}
