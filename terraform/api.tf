resource "aws_api_gateway_rest_api" "shortrace_api" {
  name = "shortrace-central-api"
}

resource "aws_api_gateway_resource" "redirect_resource" {
  rest_api_id = aws_api_gateway_rest_api.shortrace_api.id
  parent_id   = aws_api_gateway_rest_api.shortrace_api.root_resource_id

  path_part = "{codigo}"
}

resource "aws_api_gateway_method" "redirect_method" {
  rest_api_id   = aws_api_gateway_rest_api.shortrace_api.id
  resource_id   = aws_api_gateway_resource.redirect_resource.id

  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.codigo" = true
  }
}

resource "aws_api_gateway_integration" "redirect_integration" {

  rest_api_id = aws_api_gateway_rest_api.shortrace_api.id
  resource_id = aws_api_gateway_resource.redirect_resource.id

  http_method = aws_api_gateway_method.redirect_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = aws_lambda_function.redirect_lambda.invoke_arn
}

resource "aws_lambda_permission" "redirect_permission" {

  statement_id = "AllowRedirectInvoke"

  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect_lambda.function_name

  principal = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_deployment" "deployment" {

  depends_on = [
    aws_api_gateway_integration.redirect_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.shortrace_api.id

  triggers = {
    redeployment = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {

  stage_name = "dev"

  rest_api_id = aws_api_gateway_rest_api.shortrace_api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

