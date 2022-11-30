
# create RDS SQL SERVER db instance
resource "aws_db_instance" "this" {
  count                         = var.enabled ? 1 : 0
  allocated_storage             = var.allocated_storage
  allow_major_version_upgrade   = var.allow_major_version_upgrade
  auto_minor_version_upgrade    = var.auto_minor_version_upgrade
  max_allocated_storage         = var.max_allocated_storage
  maintenance_window            = var.maintenance_window
  monitoring_interval           = var.monitoring_interval
  backup_retention_period       = var.backup_retention_period
  backup_window                 = var.backup_window
  deletion_protection           = var.deletion_protection
  db_subnet_group_name          = aws_db_subnet_group.this.*.id[0]
  character_set_name            = var.character_set_name
  engine                        = var.engine 
  engine_version                = var.engine_version
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  identifier                    = var.identifier
  instance_class                = var.instance_class
  username                      = local.sso_secrets.username
  password                      = local.sso_secrets.password
  skip_final_snapshot           = var.skip_final_snapshot
  storage_encrypted             = var.storage_encrypted
  # storage_type                = var.storage_type
  vpc_security_group_ids        = var.vpc_security_group_ids
  publicly_accessible           = var.publicly_accessible
  apply_immediately             = var.apply_immediately
  license_model                 = var.license_model
  option_group_name             = var.option_group_name
  port                          = var.port
  parameter_group_name          = var.parameter_group_name
  performance_insights_enabled  = var.performance_insights_enabled
  tags                          = var.tags
  multi_az                      = var.multi_az
  timezone                      = var.timezone
  final_snapshot_identifier     = var.final_snapshot_identifier_prefix

  depends_on = [
    aws_db_subnet_group.this,
    aws_secretsmanager_secret.this,
    aws_secretsmanager_secret_version.this

  ]
}

# create db subnet group
resource "aws_db_subnet_group" "this" {
  count                         = var.enabled ? 1 : 0
  name                          = "${var.identifier}-subnet-group"
  description                   = "Created by terraform"
  subnet_ids                    = var.subnet_ids
  tags                          = var.tags
}


#  create a random generated password which we will use in secrets.
resource "random_password" "password" {
  length                        = 12
  special                       = true
  min_special                   = 2
  override_special              = "_%"
}


# create secret and secret versions for database master account 

resource "aws_secretsmanager_secret" "this" {
  name                          = var.secret_manager_name
  recovery_window_in_days       = 7
  tags                          = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id                     = aws_secretsmanager_secret.this.id
  secret_string = <<EOF
   {
    "username": "admin",
    "password": "${random_password.password.result}"
   }
EOF
}
