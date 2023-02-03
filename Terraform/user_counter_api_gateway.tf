# API Gateway

# REST API
resource "aws_api_gateway_rest_api" "PortfolioAPIGateway" {
  name        = "PortfolioAPIGateway"
  description = "Portfolio Website API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Resource for User Counter(path end for URL)
resource "aws_api_gateway_resource" "user-counter-api-resource" {
  parent_id   = aws_api_gateway_rest_api.PortfolioAPIGateway.root_resource_id
  path_part   = "count"
  rest_api_id = aws_api_gateway_rest_api.PortfolioAPIGateway.id
}

# Request POST Method
resource "aws_api_gateway_method" "api-post-method" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.user-counter-api-resource.id
  rest_api_id   = aws_api_gateway_rest_api.PortfolioAPIGateway.id
}

# POST method Integration (link to Lambda function)
resource "aws_api_gateway_integration" "api-lambda-integration" {
  rest_api_id             = aws_api_gateway_rest_api.PortfolioAPIGateway.id
  resource_id             = aws_api_gateway_resource.user-counter-api-resource.id
  http_method             = aws_api_gateway_method.api-post-method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.user_counter_lambda_func.invoke_arn
}

# Deployment (to stage for use)
resource "aws_api_gateway_deployment" "user-counter-api-deployment" {
  rest_api_id = aws_api_gateway_rest_api.PortfolioAPIGateway.id
  depends_on = [
      aws_api_gateway_resource.user-counter-api-resource,
      aws_api_gateway_method.api-post-method,
      aws_api_gateway_integration.api-lambda-integration,
    ]
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.user-counter-api-resource.id,
      aws_api_gateway_method.api-post-method.id,
      aws_api_gateway_integration.api-lambda-integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Stage

resource "aws_api_gateway_stage" "api-stage" {
  deployment_id = aws_api_gateway_deployment.user-counter-api-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.PortfolioAPIGateway.id
  stage_name    = "prod"
}

# Permission (from Lambda to API)

resource "aws_lambda_permission" "user-counter-lambda-permission-to-api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "User_Counter_Lambda_Function"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.PortfolioAPIGateway.execution_arn}/*/${aws_api_gateway_method.api-post-method.http_method}/${aws_api_gateway_resource.user-counter-api-resource.path_part}"
}

# Response Codes

resource "aws_api_gateway_method_response" "user-counter-response_200" {
  rest_api_id = aws_api_gateway_rest_api.PortfolioAPIGateway.id
  resource_id = aws_api_gateway_resource.user-counter-api-resource.id
  http_method = aws_api_gateway_method.api-post-method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "user-counter-IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.PortfolioAPIGateway.id
  resource_id = aws_api_gateway_resource.user-counter-api-resource.id
  http_method = aws_api_gateway_method.api-post-method.http_method
  status_code = aws_api_gateway_method_response.user-counter-response_200.status_code
  depends_on = [aws_api_gateway_integration.api-lambda-integration]
}

# Enable CORS

module "api-gateway-enable-cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.PortfolioAPIGateway.id
  api_resource_id = aws_api_gateway_resource.user-counter-api-resource.id
}