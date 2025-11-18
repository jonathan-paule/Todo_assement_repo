resource "aws_lambda_function" "todo_lambda" {
  function_name = "todo-crud"
  runtime       = "python3.12"
  handler       = "app.lambda_handler"
  filename      = "lambda.zip"

  environment {
    variables = {
      DB_HOST = aws_db_instance.todo_db.address
      DB_USER = var.db_user
      DB_PASS = var.db_password
      DB_NAME = "todos"
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
