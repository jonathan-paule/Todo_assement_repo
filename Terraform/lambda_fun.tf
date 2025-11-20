resource "aws_lambda_function" "todo_lambda" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = "todo-api.lambda_handler"
  filename      = var.filename
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      DB_NAME     = var.db_name
      DB_USERNAME = var.db_username
      DB_PASSWORD = var.db_password
      DB_HOST     = aws_db_instance.todo_db.address
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id,
                          aws_subnet.private_subnet2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
