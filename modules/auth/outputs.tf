
output secret_name {
  value = local.auth0_config_secret_name
}

output secret_arn {
  value = aws_secretsmanager_secret_version.auth0_config.arn
}