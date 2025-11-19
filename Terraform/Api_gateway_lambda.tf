data "aws_caller_identity" "current" {}


resource "aws_apigatewayv2_api" "todo_api" {
  name          = var.api_name  #todo-http-api is the name
  protocol_type = var.protocol_type
}



resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.todo_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.todo_lambda.invoke_arn
 
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "ANY /todos/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "todos_root" {
  api_id    = aws_apigatewayv2_api.todo_api.id
  route_key = "ANY /todos"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.todo_api.id
  name        = "$default"
  auto_deploy = true
}
