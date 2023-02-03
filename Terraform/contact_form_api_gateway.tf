# API Resource for Contact Form(path end for URL)
resource "aws_api_gateway_resource" "contact-form-api-resource" {
  parent_id   = aws_api_gateway_rest_api.PortfolioAPIGateway.root_resource_id
  path_part   = "ses_contact_me"
  rest_api_id = aws_api_gateway_rest_api.PortfolioAPIGateway.id
}

# Request POST Method
resource "aws_api_gateway_method" "contact-form-api-post-method" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.contact-form-api-resource.id
  rest_api_id   = aws_api_gateway_rest_api.PortfolioAPIGateway.id
}

# POST method Integration (link to Lambda function)
resource "aws_api_gateway_integration" "contact-form-api-lambda-integration" {
  rest_api_id             = aws_api_gateway_rest_api.PortfolioAPIGateway.id
  resource_id             = aws_api_gateway_resource.contact-form-api-resource.id
  http_method             = aws_api_gateway_method.contact-form-api-post-method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.contact_form_lambda_func.invoke_arn
}

# Deployment (to stage for use)
# resource "aws_api_gateway_deployment" "contact-form-api-deployment" {
#   rest_api_id = aws_api_gateway_rest_api.PortfolioAPIGateway.id
#   triggers = {
#     redeployment = sha1(jsonencode([
#       aws_api_gateway_resource.contact-form-api-resource.id,
#       aws_api_gateway_method.contact-form-api-post-method.id,
#       aws_api_gateway_integration.contact-form-api-lambda-integration.id,
#     ]))
#   }
#   depends_on = [
#       aws_api_gateway_method.contact-form-api-post-method,
#       aws_api_gateway_integration.contact-form-api-lambda-integration,
#     ]
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # Stage

# resource "aws_api_gateway_stage" "api-stage" {
#   deployment_id = aws_api_gateway_deployment.contact-form-api-deployment.id
#   rest_api_id   = aws_api_gateway_rest_api.PortfolioAPIGateway.id
#   stage_name    = "prod"
# }

# Permission (from Lambda to API)

resource "aws_lambda_permission" "contact-form-lambda-permission-to-api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "Contact_Form_Lambda_Function"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.PortfolioAPIGateway.execution_arn}/*/${aws_api_gateway_method.contact-form-api-post-method.http_method}/${aws_api_gateway_resource.contact-form-api-resource.path_part}"
}

# Response Codes

resource "aws_api_gateway_method_response" "contact-form-response_200" {
  rest_api_id = aws_api_gateway_rest_api.PortfolioAPIGateway.id
  resource_id = aws_api_gateway_resource.contact-form-api-resource.id
  http_method = aws_api_gateway_method.contact-form-api-post-method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "contact-form-IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.PortfolioAPIGateway.id
  resource_id = aws_api_gateway_resource.contact-form-api-resource.id
  http_method = aws_api_gateway_method.contact-form-api-post-method.http_method
  status_code = aws_api_gateway_method_response.contact-form-response_200.status_code
  depends_on = [aws_api_gateway_integration.contact-form-api-lambda-integration]
}