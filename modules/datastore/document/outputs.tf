
output "arn" {
  value = aws_dynamodb_table.documents.arn
}

output "id" {
  value = aws_dynamodb_table.documents.id
}

output "table" {
  value = aws_dynamodb_table.documents
}