resource "aws_lambda_function" "todo_lambda" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = "todo-api.lambda_handler"
  filename      = var.filename
  role          = aws_iam_role.lambda_exec_role.arn

 environment {
    variables = {
      DB_SECRET_NAME = aws_secretsmanager_secret.db.name
      REGION      = var.region
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id,
                          aws_subnet.private_subnet2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
