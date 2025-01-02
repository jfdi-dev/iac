
resource "aws_ssm_parameter" "param" {
  tier = "Advanced"
  name = var.name
  type = "String"
  value = var.value
}

resource "aws_ram_resource_share" "param_share" {
  name                      = var.name
  allow_external_principals = false

  tags = var.tags
}

resource "aws_ram_resource_association" "param_share" {
  resource_arn       = aws_ssm_parameter.param.arn
  resource_share_arn = aws_ram_resource_share.param_share.arn
}

resource "aws_ram_principal_association" "param_share" {
  for_each = var.shared_with
  resource_share_arn = aws_ram_resource_share.param_share.arn
  principal          = each.value
}