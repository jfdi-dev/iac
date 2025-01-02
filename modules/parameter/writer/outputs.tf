
output "value" {
  value = { "${aws_ssm_parameter.param.name}" = aws_ssm_parameter.param.value }
  sensitive = true
}