output "api_gateway_endpoint" {
  description = "Invoke URL for the Todo API"
  value       = aws_apigatewayv2_api.todo_api.api_endpoint
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.todo_db.address
}
