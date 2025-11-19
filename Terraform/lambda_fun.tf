resource "aws_lambda_function" "todo_lambda" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = "app.lambda_handler"
  filename      = var.filename
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
