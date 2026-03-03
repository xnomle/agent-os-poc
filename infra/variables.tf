variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-southeast-2"
}

variable "lambda_zip_path" {
  description = "Path to the zipped Lambda deployment package"
  type        = string
  default     = "../lambda.zip"
}
