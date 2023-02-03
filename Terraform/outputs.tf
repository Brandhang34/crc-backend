output "deployment_invoke_url" {
  description = "Deployment invoke url"
  value       = "${aws_api_gateway_deployment.user-counter-api-deployment.invoke_url}${aws_api_gateway_stage.api-stage.stage_name}/${aws_api_gateway_resource.user-counter-api-resource.path_part} \n ${aws_api_gateway_deployment.user-counter-api-deployment.invoke_url}${aws_api_gateway_stage.api-stage.stage_name}/${aws_api_gateway_resource.contact-form-api-resource.path_part}"
}