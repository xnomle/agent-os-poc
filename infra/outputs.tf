output "invoke_url" {
  description = "API Gateway invoke URL for the POST / endpoint"
  value       = aws_apigatewayv2_stage.default.invoke_url
}
