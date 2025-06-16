moved {
  from = aws_kms_alias.database
  to   = module.database.aws_kms_alias.database
}

moved {
  from = aws_kms_key.database
  to   = module.database.aws_kms_key.database
}

moved {
  from = module.database_security_group.aws_security_group.this_name_prefix
  to   = module.database.module.database_security_group.aws_security_group.this_name_prefix
}

moved {
  from = module.mssql.module.db_instance.aws_db_instance.this
  to   = module.database.module.mssql["this"].module.db_instance.aws_db_instance.this
}

moved {
  from = module.mssql.module.db_instance.aws_iam_role.enhanced_monitoring
  to   = module.database.module.mssql["this"].module.db_instance.aws_iam_role.enhanced_monitoring
}

moved {
  from = module.mssql.module.db_instance.aws_iam_role_policy_attachment.enhanced_monitoring
  to   = module.database.module.mssql["this"].module.db_instance.aws_iam_role_policy_attachment.enhanced_monitoring
}

moved {
  from = module.mssql.module.db_instance.random_id.snapshot_identifier
  to   = module.database.module.mssql["this"].module.db_instance.random_id.snapshot_identifier
}

moved {
  from = module.mssql.module.db_parameter_group.aws_db_parameter_group.this
  to   = module.database.module.mssql["this"].module.db_parameter_group.aws_db_parameter_group.this
}

moved {
  from = module.mssql.module.db_subnet_group.aws_db_subnet_group.this
  to   = module.database.module.mssql["this"].module.db_subnet_group.aws_db_subnet_group.this
}
