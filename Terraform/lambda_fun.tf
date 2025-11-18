resource "aws_lambda_function" "todo_lambda" {
  function_name = "todo-crud"
  runtime       = "python3.12"
  handler       = "app.lambda_handler"
  filename      = "lambda/todo-api.zip"
  role          = aws_iam_role.lambda_exec_role.arn

 environment {
    variables = {
      SECRET_NAME = "todoapp/db_credentials"
      REGION      = var.region
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
