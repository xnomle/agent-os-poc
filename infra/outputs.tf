output "invoke_url" {
  description = "API Gateway invoke URL for the POST / endpoint"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.hello_world.function_name
}
